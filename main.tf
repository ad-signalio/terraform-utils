data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name = var.env_name
  eks_managed_node_groups = var.use_auto_mode ? null : {
    default = {
      subnet_ids = var.subnets_in_az
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      instance_types = [var.node_instance_type]
      ami_type       = "AL2023_x86_64_STANDARD"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            delete_on_termination = true
            encrypted             = false
          }
        }
      }

      launch_template_tags = var.tags
      tag_specifications   = ["instance", "volume", "network-interface"]
      min_size             = var.node_count
      max_size             = var.node_count
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = var.node_count

      iam_role_additional_policies = {
        ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
      tags = var.tags
    }
  }
  # Due to the current EKS Auto Mode API, to disable EKS Auto Mode 
  # you will have to explicity set: false
  # node_pools = null, not [], when using custom pools. The upstream module reads
  # `node_pools != null` to decide whether to set the cluster's node_role_arn, and
  # an empty list is not null -- so [] would still set it. null gives the state AWS
  # documents for a cluster without built-in node pools.
  #
  # The node IAM role is still created either way: create_node_iam_role keys off
  # compute_config.enabled, not off node_pools.
  compute_config = var.use_auto_mode ? {
    enabled    = var.use_auto_mode
    node_pools = var.use_builtin_node_pools ? ["system", "general-purpose"] : null
    } : {
    enabled    = false
    node_pools = []
  }

  # Addons that run Deployments, so terraform's wait for them to become healthy
  # cannot succeed until the cluster has compute. Under Auto Mode with custom
  # node pools -- what tagged compute requires -- that compute is a Kubernetes
  # CRD, so it cannot be planned until the cluster exists and therefore arrives
  # in a later apply than the cluster itself. Callers in that position set
  # create_compute_dependent_addons = false for the apply that creates the
  # cluster, and leave it at the default afterwards.
  compute_dependent_add_ons = {
    aws-efs-csi-driver = {
      service_account_role_arn = module.efs_csi_irsa.arn
    }
    metrics-server = {}
  }

  # auto mode handles ebs and vpc cni
  add_ons = var.use_auto_mode ? merge(
    var.create_compute_dependent_addons ? local.compute_dependent_add_ons : {},
    {
      aws-secrets-store-csi-driver-provider = {
        addon_version               = var.ascp_addon_version
        resolve_conflicts_on_update = "OVERWRITE"
        service_account_role_arn    = module.secrets_csi_irsa.arn
        namespace                   = "kube-system"
        configuration_values = jsonencode({
          secrets-store-csi-driver = {
            enableSecretRotation = true
            rotationPollInterval = "3600s"
            syncSecret = {
              enabled = true
            }
          }
        })
      }
    }
    ) : {
    coredns    = {}
    kube-proxy = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    vpc-cni = {
      before_compute              = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    aws-efs-csi-driver = {
      service_account_role_arn = module.efs_csi_irsa.arn
    }
    aws-ebs-csi-driver = {}
    aws-secrets-store-csi-driver-provider = {
      addon_version               = var.ascp_addon_version
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.secrets_csi_irsa.arn
      namespace                   = "kube-system"
      configuration_values = jsonencode({
        secrets-store-csi-driver = {
          enableSecretRotation = true
          rotationPollInterval = "3600s"
          syncSecret = {
            enabled = true
          }
        }
      })
    }
    metrics-server = {}
  }
}

module "eks_al2023_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.15.1"

  name               = local.name
  kubernetes_version = var.kubernetes_version

  endpoint_private_access                = true
  endpoint_public_access                 = true
  ip_family                              = "ipv4"
  enabled_log_types                      = ["api", "audit", "authenticator", "scheduler"]
  cloudwatch_log_group_retention_in_days = 30

  create_auto_mode_iam_resources = true
  compute_config                 = local.compute_config

  control_plane_scaling_config = {
    tier = "standard"
  }

  # EKS Addons
  addons = local.add_ons

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # env_name is already unique per environment -- no need for a name_prefix.
  iam_role_use_name_prefix        = false
  include_oidc_root_ca_thumbprint = false

  eks_managed_node_groups = local.eks_managed_node_groups

  access_entries                           = var.access_entries
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  tags                      = var.tags
  cloudwatch_log_group_tags = var.tags

  node_security_group_additional_rules = {
    ingress_nfs_vpc = {
      description = "Allow NFS ingress from VPC CIDR for EFS"
      protocol    = "tcp"
      from_port   = 2049
      to_port     = 2049
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr_block]
    }
  }
}


data "aws_eks_cluster_auth" "this" {
  name = module.eks_al2023_cluster.cluster_name
}



# Access entry for the Auto Mode node IAM role.
#
# EKS creates this itself for the built-in node pools, but not for a custom
# NodeClass -- and without it nodes cannot join the cluster. Created here rather
# than through the EKS module's access_entries input, which would be a cycle:
# the entry needs the role ARN that module produces.
resource "aws_eks_access_entry" "auto_node" {
  count = var.use_auto_mode && !var.use_builtin_node_pools ? 1 : 0

  cluster_name  = module.eks_al2023_cluster.cluster_name
  principal_arn = module.eks_al2023_cluster.node_iam_role_arn
  type          = "EC2"

  tags = var.tags
}

resource "aws_eks_access_policy_association" "auto_node" {
  count = var.use_auto_mode && !var.use_builtin_node_pools ? 1 : 0

  cluster_name  = module.eks_al2023_cluster.cluster_name
  principal_arn = module.eks_al2023_cluster.node_iam_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.auto_node]
}
