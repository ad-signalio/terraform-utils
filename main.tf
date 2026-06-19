# GKE Gateway (Gateway API) for exposing an app via a GKE-managed L7 load
# balancer. Wraps the reserved global external IP + the Gateway resource.
#
# The HTTP:80 listener is always present. When enable_tls = true, an HTTPS:443
# listener (terminating TLS from tls_secret_name) is added and a reserved static
# IP is bound to the Gateway (DNS needs a stable target for the cert).
#
# The TLS cert itself is NOT created here — tls_secret_name is expected to be
# populated externally (e.g. a cert-manager Certificate shipped by the app
# chart, or a manually-created Secret). This keeps the cloud-infra Gateway
# decoupled from the app-coupled cert.

locals {
  create_ip = var.create_static_ip != null ? var.create_static_ip : var.enable_tls
  ip_name   = coalesce(var.static_ip_name, "${var.gateway_name}-ip")
}

resource "google_compute_global_address" "gateway" {
  count   = local.create_ip ? 1 : 0
  project = var.project_id
  name    = local.ip_name
}

resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name        = var.gateway_name
      namespace   = var.namespace
      annotations = var.annotations
    }
    spec = merge(
      {
        gatewayClassName = var.gateway_class_name
        listeners = concat(
          [{
            name          = "http"
            protocol      = "HTTP"
            port          = 80
            allowedRoutes = { namespaces = { from = var.allowed_routes_from } }
          }],
          var.enable_tls ? [{
            name     = "https"
            protocol = "HTTPS"
            port     = 443
            hostname = var.hostname
            tls = {
              mode            = "Terminate"
              certificateRefs = [{ kind = "Secret", name = var.tls_secret_name }]
            }
            allowedRoutes = { namespaces = { from = var.allowed_routes_from } }
          }] : []
        )
      },
      local.create_ip ? {
        addresses = [{ type = "NamedAddress", value = google_compute_global_address.gateway[0].name }]
      } : {}
    )
  }

  lifecycle {
    precondition {
      condition     = !var.enable_tls || var.hostname != ""
      error_message = "hostname is required when enable_tls = true (the HTTPS listener and its TLS cert need a host)."
    }
  }
}
