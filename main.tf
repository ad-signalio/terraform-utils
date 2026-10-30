# helm_release, not kubernetes_manifest: the secret names are unknown at plan
# time, which kubernetes_manifest rejects.
resource "helm_release" "secrets_configuration" {
  count = var.enabled ? 1 : 0

  name             = var.release_name
  repository       = var.chart_repository
  chart            = var.chart_name
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace

  wait    = var.wait
  timeout = var.timeout

  values = [yamlencode({
    clusterName        = var.cluster_name
    secretStoreRoleArn = var.secret_store_role_arn
    apiSecretName      = var.api_secret_name
    rdsPgSecretName    = var.rds_pg_secret_name
    userSecretName     = var.user_secret_name

    dockerSecretName      = var.docker_secret_name
    honeybadgerSecretName = var.honeybadger_secret_name

    k8sSecretNames = {
      rdsPg = var.k8s_rds_pg_secret_name
      api   = var.k8s_api_secret_name
      user  = var.k8s_owning_user_secret_name
    }

    smtp = {
      enabled        = var.smtp_secret_name != ""
      smtpSecretName = var.smtp_secret_name
    }

    secretSyncer = {
      enabled = true
      image   = var.secret_syncer_image
    }
  })]

  lifecycle {
    precondition {
      condition     = !contains(["0.1.0", "0.2.0", "0.3.0"], var.chart_version)
      error_message = "chart_version must be 0.4.0 or later. Earlier charts render a Redis SecretProviderClass that this module no longer gives a secret name, so the syncer pod never starts."
    }
  }
}
