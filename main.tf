data "http" "keda_crds" {
  url = "https://github.com/kedacore/keda/releases/download/v${var.chart_version}/keda-${var.chart_version}-crds.yaml"
}

locals {
  # Split multi-document YAML by "---" 
  # We use try() because splitting can create empty strings or fragments that aren't valid YAML, 
  # which causes yamldecode to crash.
  raw_crds = [
    for doc in split("---", data.http.keda_crds.response_body) :
    try(yamldecode(doc), null)
    if length(trimspace(doc)) > 0
  ]

  # Filter out any nulls (failed parses or empty docs)
  crds = [
    for crd in local.raw_crds :
    crd
    if crd != null
  ]
}

data "aws_eks_clusters" "default" {}

locals {
  cluster_created = contains(data.aws_eks_clusters.default.names, var.eks_cluster_name)
}

resource "kubernetes_manifest" "keda_crds" {
  count = var.enabled && var.install_crds ? length(local.crds) : 0

  manifest = local.crds[count.index]
}

resource "helm_release" "keda" {
  count            = var.enabled ? 1 : 0
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  # Disable built-in CRD installation since we manage them manually
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
