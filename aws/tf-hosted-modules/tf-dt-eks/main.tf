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
  compute_config = var.use_auto_mode ? {
    enabled    = var.use_auto_mode
    node_pools = ["system", "general-purpose"]
    } : {
    enabled    = false
    node_pools = []
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
  compute_config = {
    enabled    = true
    node_pools = ["system", "general-purpose"]
  }

  control_plane_scaling_config = {
    tier = "standard"
  }

  # EKS Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute              = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa.arn
    }
    aws-efs-csi-driver = {
      service_account_role_arn = module.efs_csi_irsa.arn
    }
    aws-secrets-store-csi-driver-provider = {
      service_account_role_arn = module.secrets_csi_irsa.arn
      namespace                = "kube-system"
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

  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  iam_role_use_name_prefix        = var.iam_role_use_name_prefix
  include_oidc_root_ca_thumbprint = false

  eks_managed_node_groups = local.eks_managed_node_groups

  access_entries = merge(
    local.infra_admin_roles,
    local.infra_admin_sso_permission_sets,
  var.extra_access_entries)

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

data "aws_iam_roles" "sso_permset" {
  for_each    = toset(var.admin_access_sso_permission_set_names)
  name_regex  = "AWSReservedSSO_${each.key}.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

locals {
  infra_admin_roles = {
    for role_name in var.admin_access_role_names : role_name => {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${role_name}"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  permission_set_roles = flatten([
    for permsets in data.aws_iam_roles.sso_permset : permsets.arns
  ])

  infra_admin_sso_permission_sets = {
    for permset_role in local.permission_set_roles : element(split("/", permset_role), -1) => {
      principal_arn = permset_role
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_al2023_cluster.cluster_name
}


