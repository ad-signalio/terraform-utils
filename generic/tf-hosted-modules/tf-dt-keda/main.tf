resource "helm_release" "keda" {
  count            = var.enabled ? 1 : 0
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  # Temp reenable built-in CRD installation since we manage them manually
  skip_crds = var.install_crds

  values = concat(var.values, [
    yamlencode({
      crds = {
        install = var.install_crds
      }
      watchNamespace = "match"
    }),
    yamlencode(var.settings)
  ])

  depends_on = [kubernetes_manifest.keda_crds]
}
