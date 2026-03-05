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

  # auto mode handles ebs and vpc cni
  add_ons = var.use_auto_mode ? {
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
    } : {
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

  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  iam_role_use_name_prefix        = var.iam_role_use_name_prefix
  include_oidc_root_ca_thumbprint = false

  eks_managed_node_groups = local.eks_managed_node_groups

  access_entries                           = var.access_entries
  enable_cluster_creator_admin_permissions = true

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


