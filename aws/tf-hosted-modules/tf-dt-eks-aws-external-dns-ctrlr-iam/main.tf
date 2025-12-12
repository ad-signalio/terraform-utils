data "aws_region" "current" {}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

locals {
  feature   = "external-dns"
  namespace = "kube-system"
  name      = var.env_name
}

module "iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name                          = "${local.name}-eks-${local.feature}"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = [data.aws_route53_zone.this.arn]
  use_name_prefix               = var.use_name_prefix

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${local.feature}"]
    }
  }
  tags = var.tags
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = local.feature
    namespace = local.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_role.arn
    }
  }
}

