output "k8s_secret_names" {
  description = "Kubernetes Secrets the chart syncs Secrets Manager into."
  value = var.enabled ? {
    api         = "match-api-secrets"
    owning_user = "match-owning-user-credentials"
    rds_pg      = var.k8s_rds_pg_secret_name
    redis       = "${var.cluster_name}-redis"
    docker      = "dockerconfig"
    honeybadger = "honeybadger-api-key"
    smtp        = var.smtp_secret_name != "" ? "smtp-secrets" : null
  } : {}
}

output "match_helm_values" {
  description = "Values the match chart needs so it consumes these Secrets instead of generating its own. See README."
  value = var.enabled ? yamlencode({
    secretKeys = {
      secret = { generate = false, name = "match-api-secrets" }
    }
    owningUser = {
      secret = { generate = false, name = "match-owning-user-credentials" }
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
