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

  # Snicket Labs support reaches customer environments from behind an egress
  # proxy in our ops VPC, so everything we send arrives from this one address.
  snicket_labs_egress_cidr = "18.168.92.90/32"

  # Added only where it changes something. An internal load balancer is not
  # reachable from our network whatever the security group says. An empty
  # inbound_cidrs leaves the controller's 0.0.0.0/0 default in place, so adding
  # our address there would narrow a wide-open load balancer to us alone --
  # locking out the customer rather than letting us in. And there is nothing to
  # add to a list that already admits the whole internet.
  snicket_labs_lb_access = (
    var.snicket_labs_remote_lb_access
    && var.scheme == "internet-facing"
    && length(var.inbound_cidrs) > 0
    && !contains(var.inbound_cidrs, "0.0.0.0/0")
  ) ? [local.snicket_labs_egress_cidr] : []

  inbound_cidrs = distinct(concat(var.inbound_cidrs, local.snicket_labs_lb_access))
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
        scheme = var.scheme
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
      # Left out entirely when empty: the controller's default is 0.0.0.0/0, and
      # an empty list here would lock the load balancer down to nothing rather
      # than mean "no opinion".
      length(local.inbound_cidrs) > 0 ? {
        inboundCIDRs = local.inbound_cidrs
      } : {},
    )
  }
}