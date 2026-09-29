output "k8s_secret_names" {
  description = "Kubernetes Secrets the chart syncs Secrets Manager into."
  value = var.enabled ? {
    api         = var.k8s_api_secret_name
    owning_user = var.k8s_owning_user_secret_name
    rds_pg      = var.k8s_rds_pg_secret_name
    redis       = "${var.cluster_name}-redis"
    docker      = "dockerconfig"
    honeybadger = "honeybadger-api-key"
    smtp        = var.smtp_secret_name != "" ? "smtp-secrets" : null
  } : {}
}

output "match_helm_values" {
  description = "Values the chart needs so it consumes these Secrets instead of generating its own. See README."
  value = var.enabled ? yamlencode({
    secretKeys = {
      secret = { generate = false, name = var.k8s_api_secret_name }
    }
    owningUser = {
      secret = { generate = false, name = var.k8s_owning_user_secret_name }
    }
    postgres = {
      enabled             = false
      passwordSecret      = { name = var.k8s_rds_pg_secret_name, key = "password" }
      dbNameSecret        = { name = var.k8s_rds_pg_secret_name, key = "db_name" }
      dbPrimaryHostSecret = { name = var.k8s_rds_pg_secret_name, key = "host" }
    }
  }) : ""
}

output "release_name" {
  description = "Helm release name, or null when disabled."
  value       = var.enabled ? var.release_name : null
}
