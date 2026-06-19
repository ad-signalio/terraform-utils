# GKE Gateway + (optional) cert-manager TLS, shipped as a single helm_release so
# the whole stack applies in ONE `terraform apply` alongside the cluster.
#
# Why helm and not kubernetes_manifest: kubernetes_manifest fetches the resource
# schema from the live cluster at PLAN time, so it can't be created in the same
# apply that creates the cluster. helm_release templates the chart locally at plan
# time and only talks to the API at apply (after the cluster + cert-manager exist,
# ordered via depends_on) — so no staged/tiered apply is needed. Pair with exec
# auth on the kubernetes/helm providers (lazy auth) so the providers can configure
# against the not-yet-created cluster.
#
# The chart bundles: the Gateway (HTTP + optional HTTPS listener), and when TLS is
# on, the cert-manager ClusterIssuer (Cloudflare DNS-01), the Certificate, and the
# Cloudflare API token Secret. The reserved static IP stays a Google resource here
# (plans fine without a cluster).

locals {
  create_ip = var.create_static_ip != null ? var.create_static_ip : var.enable_tls
  ip_name   = coalesce(var.static_ip_name, "${var.gateway_name}-ip")
}

resource "google_compute_global_address" "gateway" {
  count   = local.create_ip ? 1 : 0
  project = var.project_id
  name    = local.ip_name
}

resource "helm_release" "gateway_tls" {
  name             = var.release_name
  namespace        = var.namespace
  create_namespace = var.create_namespace
  chart            = "${path.module}/chart"

  values = [yamlencode({
    gatewayName       = var.gateway_name
    gatewayClassName  = var.gateway_class_name
    allowedRoutesFrom = var.allowed_routes_from
    enableTLS         = var.enable_tls
    hostname          = var.hostname
    tlsSecretName     = var.tls_secret_name
    staticIpName      = local.create_ip ? local.ip_name : ""
    clusterIssuer = {
      name       = var.cluster_issuer_name
      acmeServer = var.acme_server
      acmeEmail  = var.acme_email
    }
    cloudflare = {
      apiToken        = var.cloudflare_api_token
      namespace       = var.cert_manager_namespace
      tokenSecretName = "cloudflare-api-token"
      tokenSecretKey  = "api-token"
    }
  })]

  # Static IP must exist before the Gateway references it. The consumer is
  # responsible for depends_on = [module.gke, module.cert_manager] so the cluster
  # (Gateway API CRDs) and cert-manager (its CRDs) exist before this applies.
  depends_on = [google_compute_global_address.gateway]

  lifecycle {
    precondition {
      condition     = !var.enable_tls || (var.hostname != "" && var.cloudflare_api_token != null && var.acme_email != "")
      error_message = "When enable_tls = true you must set hostname, cloudflare_api_token, and acme_email."
    }
  }
}
