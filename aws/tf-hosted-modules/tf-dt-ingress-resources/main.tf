data "aws_caller_identity" "current" {}

## i dont like it


resource "kubernetes_cluster_role" "ingressclass_admin" {
  metadata {
    name = "ingressclass-admin"
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingressclasses"]
    verbs      = ["create", "get", "list", "watch", "update", "delete"]
  }
}

resource "kubernetes_cluster_role_binding" "ingressclass_admin_binding" {
  metadata {
    name = "ingressclass-admin-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.ingressclass_admin.metadata[0].name
  }
  subject {
    kind      = "User"
    name      = data.aws_caller_identity.current.arn
    api_group = "rbac.authorization.k8s.io"
  }
}

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