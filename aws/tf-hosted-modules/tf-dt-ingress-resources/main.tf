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

# Look the certificate up by domain, so callers can name what they own instead
# of pinning an ARN that changes every time the certificate is reissued. The
# provider's region decides which one is found, which is what you want: an ALB
# can only use a certificate from its own region.
data "aws_acm_certificate" "this" {
  count       = var.certificate_domain != "" && length(var.certificate_arns) == 0 ? 1 : 0
  domain      = var.certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

locals {
  cluster_created = contains(data.aws_eks_clusters.default.names, var.eks_cluster_name)

  # An explicit list wins over the lookup.
  certificate_arns = length(var.certificate_arns) > 0 ? var.certificate_arns : data.aws_acm_certificate.this[*].arn
}

resource "kubernetes_manifest" "match_alb_ingress_class_params" {
  count = local.cluster_created ? 1 : 0
  manifest = {
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "IngressClassParams"
    metadata = {
      name = "match-alb"
    }
    spec = merge(
      {
        scheme = "internet-facing"
        group = {
          name = "match-alb"
        }
      },
      length(var.tags) > 0 ? {
        tags = [for k, v in var.tags : { key = k, value = v }]
      } : {},
      length(local.certificate_arns) > 0 ? {
        certificateARNs = local.certificate_arns
      } : {},
      var.ssl_policy != "" ? {
        sslPolicy = var.ssl_policy
      } : {},
    )
  }
}