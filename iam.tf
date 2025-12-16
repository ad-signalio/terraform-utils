
locals {
  account_id        = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.region
  url_parts         = split("/", module.eks_al2023_cluster.cluster_oidc_issuer_url)
  oidc_id           = local.url_parts[length(local.url_parts) - 1]
  oidc_provider_arn = "arn:aws:iam::${local.account_id}:oidc-provider/oidc.eks.${local.region}.amazonaws.com/id/${local.oidc_id}"
}

module "efs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2.1"

  attach_efs_csi_policy = true

  name            = var.iam_role_use_name_prefix ? "${local.name}-role-efs" : "role-efs"
  use_name_prefix = var.iam_role_use_name_prefix

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
  tags = var.tags
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2.1"

  attach_ebs_csi_policy = true

  name            = var.iam_role_use_name_prefix ? "${local.name}-role-ebs" : "role-ebs"
  use_name_prefix = var.iam_role_use_name_prefix

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  tags = var.tags
}