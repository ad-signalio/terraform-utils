# external-dns — syncs DNS records (A/CNAME) for cluster sources (Gateway API
# HTTPRoutes, Services, Ingresses) to a DNS provider. Unlike cert-manager (which
# only creates the temporary _acme-challenge TXT records for DNS-01), external-dns
# manages the actual hostname -> address records, so an app's DNS tracks the
# Gateway/LB IP automatically (and, with policy = sync, is cleaned up on teardown).
#
# Helm-only operator module (cf. tf-dt-cert-manager / tf-dt-keda). Wired here for
# Cloudflare token auth; the controller itself is provider-agnostic.

resource "kubernetes_namespace" "this" {
  count = var.enabled && var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "cloudflare_api_token" {
  count = var.enabled && var.create_token_secret ? 1 : 0

  metadata {
    name      = var.token_secret_name
    namespace = var.namespace
  }
  data = { (var.token_secret_key) = var.cloudflare_api_token }
  type = "Opaque"

  depends_on = [kubernetes_namespace.this]

  lifecycle {
    precondition {
      condition     = var.cloudflare_api_token != null
      error_message = "cloudflare_api_token is required when create_token_secret = true."
    }
  }
}

resource "helm_release" "external_dns" {
  count = var.enabled ? 1 : 0

  name             = "external-dns"
  namespace        = var.namespace
  create_namespace = false # handled by kubernetes_namespace.this
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = var.chart_version

  values = concat(
    [yamlencode({
      provider      = var.dns_provider
      sources       = var.sources
      domainFilters = var.domain_filters
      policy        = var.policy
      txtOwnerId    = var.txt_owner_id
      # Cloudflare provider reads CF_API_TOKEN from the env.
      env = [{
        name = "CF_API_TOKEN"
        valueFrom = {
          secretKeyRef = {
            name = var.token_secret_name
            key  = var.token_secret_key
          }
        }
      }]
    })],
    [yamlencode(var.settings)],
    var.values
  )

  depends_on = [
    kubernetes_namespace.this,
    kubernetes_secret.cloudflare_api_token,
  ]
}
