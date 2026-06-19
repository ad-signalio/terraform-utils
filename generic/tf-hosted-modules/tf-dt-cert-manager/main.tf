# Install cert-manager (controller + CRDs) via Helm — same pattern as
# tf-dt-external-secrets / tf-dt-keda. This installs the operator only;
# ClusterIssuers and Certificates are environment-owned (the Cloudflare DNS-01
# API token is a per-environment secret, not a shared-module input).
#
# The Gateway API feature gate is enabled so cert-manager's gateway-shim can
# auto-issue + renew certs for Gateways annotated with cert-manager.io/cluster-issuer.
# Without it, cert-manager ignores Gateway listener certificateRefs.
resource "helm_release" "cert_manager" {
  count      = var.enabled ? 1 : 0
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_version
  namespace  = var.namespace

  create_namespace = true
  cleanup_on_fail  = true

  values = concat(var.values, [
    yamlencode({
      crds         = { enabled = true }
      featureGates = "ExperimentalGatewayAPISupport=true"
    }),
    yamlencode(var.settings),
  ])
}
