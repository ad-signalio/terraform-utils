
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

  name            = "${local.name}-role-efs"
  policy_name     = "${local.name}-role-efs"
  use_name_prefix = false

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa", "kube-system:efs-csi-node-sa"]
    }
  }
  tags = var.tags
}

module "ebs_csi_irsa" {
  count   = var.use_auto_mode ? 0 : 1
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2.1"

  attach_ebs_csi_policy = true

  name            = "${local.name}-role-ebs"
  policy_name     = "${local.name}-role-ebs"
  use_name_prefix = false

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  tags = var.tags
}


module "secrets_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2.1"

  attach_external_secrets_policy = true
  external_secrets_secrets_manager_arns = [
    "arn:aws:secretsmanager:*:*:secret:${var.secret_naming_convention}*",
    # Created by hand by the customer, so the names are fixed rather than
    # derived. The adsignal-match and platform charts use different ones and
    # both are listed so the two can run side by side during a cutover.
    "arn:aws:secretsmanager:*:*:secret:match-docker-secret*",
    "arn:aws:secretsmanager:*:*:secret:match-honeybadger-secret*",
    "arn:aws:secretsmanager:*:*:secret:snicketlabs-docker-secret*",
    "arn:aws:secretsmanager:*:*:secret:snicketlabs-honeybadger-secret*",
  ]

  name            = "${var.env_name}-secrets-role"
  policy_name     = "${var.env_name}-secrets-role"
  use_name_prefix = false

  oidc_providers = {
    main = {
      provider_arn = local.oidc_provider_arn
      # Must match the service accounts that exist in the cluster. Namespaced,
      # so the platform chart's namespace needs its own entry.
      namespace_service_accounts = var.secret_sync_namespace_service_accounts
    }
  }
  tags = var.tags
}
