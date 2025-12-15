data "aws_region" "current" {}

locals {
  feature   = "aws-load-balancer-controller"
  namespace = "kube-system"
  name      = var.env_name
}

module "lb_role" {
  source                                 = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  name                                   = "${local.name}-eks-lb"
  attach_load_balancer_controller_policy = true
  use_name_prefix                        = var.use_name_prefix

  oidc_providers = {
    main = {
      provider_arn               = var.eks_cluster.oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${local.feature}"]
    }
  }
  tags = var.tags
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = local.feature
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/name"      = local.feature
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.lb_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "this" {
  count      = var.install_helm_charts ? 1 : 0
  name       = local.feature
  repository = "https://aws.github.io/eks-charts"
  chart      = local.feature
  namespace  = local.namespace

  set = [
    {
      name  = "region"
      value = data.aws_region.current.region
    },

    {
      name  = "vpcId"
      value = var.vpc

    },

    {
      name  = "serviceAccount.create"
      value = "false"
    },

    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.this.metadata[0].name
    },

    {
      name  = "clusterName"
      value = local.name
    }
  ]
}
