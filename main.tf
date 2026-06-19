# Install the External Secrets Operator (controller + CRDs) via Helm — the same
# pattern as tf-dt-keda. This installs the operator only; SecretStore /
# ExternalSecret resources are deployed separately by the secrets-configuration
# eso-support chart (sc-22517).
resource "helm_release" "external_secrets" {
  count      = var.enabled ? 1 : 0
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.chart_version
  namespace  = var.namespace

  create_namespace = true
  cleanup_on_fail  = true

  values = concat(var.values, [
    yamlencode(var.settings),
  ])
}
