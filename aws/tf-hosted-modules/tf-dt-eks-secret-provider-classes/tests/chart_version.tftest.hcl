mock_provider "helm" {}

variables {
  enabled               = true
  cluster_name          = "test-cluster"
  secret_store_role_arn = "arn:aws:iam::123456789012:role/test"
  api_secret_name       = "test-api"
  user_secret_name      = "test-user"
  rds_pg_secret_name    = "test-rds-pg"
}

run "default_chart_renders_without_redis" {
  command = plan

  assert {
    condition     = !contains(keys(yamldecode(helm_release.secrets_configuration[0].values[0])), "redis")
    error_message = "The chart values should carry no redis key."
  }

  assert {
    condition     = !contains(keys(output.k8s_secret_names), "redis")
    error_message = "k8s_secret_names should not name a Redis Secret."
  }
}

run "chart_with_redis_is_refused" {
  command = plan

  variables {
    chart_version = "0.3.0"
  }

  expect_failures = [helm_release.secrets_configuration]
}
