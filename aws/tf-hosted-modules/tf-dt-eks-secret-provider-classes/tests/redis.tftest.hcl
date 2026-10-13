mock_provider "helm" {}

variables {
  enabled               = true
  cluster_name          = "test-cluster"
  secret_store_role_arn = "arn:aws:iam::123456789012:role/test"
  api_secret_name       = "test-api"
  user_secret_name      = "test-user"
  rds_pg_secret_name    = "test-rds-pg"
}

run "redis_set_keeps_redis" {
  command = plan

  variables {
    redis_secret_name = "test-redis"
  }

  assert {
    condition     = yamldecode(helm_release.secrets_configuration[0].values[0]).redis.enabled == true
    error_message = "redis.enabled should be true when redis_secret_name is set."
  }

  assert {
    condition     = yamldecode(helm_release.secrets_configuration[0].values[0]).redisSecretName == "test-redis"
    error_message = "redisSecretName should pass through unchanged."
  }

  assert {
    condition     = output.k8s_secret_names.redis == "test-cluster-redis"
    error_message = "k8s_secret_names.redis should name the synced Secret."
  }
}

run "redis_unset_disables_redis" {
  command = plan

  assert {
    condition     = yamldecode(helm_release.secrets_configuration[0].values[0]).redis.enabled == false
    error_message = "redis.enabled should be false when redis_secret_name is empty."
  }

  assert {
    condition     = output.k8s_secret_names.redis == null
    error_message = "k8s_secret_names.redis should be null without Redis."
  }
}

run "redis_unset_on_old_chart_is_refused" {
  command = plan

  variables {
    chart_version = "0.2.0"
  }

  expect_failures = [helm_release.secrets_configuration]
}
