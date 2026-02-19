resource "kubernetes_ingress_class_v1" "match_alb" {
  metadata {
    name = "match-alb"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }

  spec {
    controller = "eks.amazonaws.com/alb"
    parameters {
      api_group = "eks.amazonaws.com"
      kind      = "IngressClassParams"
      name      = "match-alb"
    }
  }
}

data "aws_eks_clusters" "default" {}

locals {
  cluster_created = contains(data.aws_eks_clusters.default.names, var.eks_cluster_name)
}

resource "kubernetes_manifest" "match_alb_ingress_class_params" {
  count = local.cluster_created ? 1 : 0
  manifest = {
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "IngressClassParams"
    metadata = {
      name = "match-alb"
    }
    spec = {
      scheme = "internet-facing"
      group = {
        name = "match-alb"
      }
    }
  }
}