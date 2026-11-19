output "role_arn" {
  value = module.iam_assumable_role_with_oidc.iam_role_arn
}

output "role_name" {
  value = module.iam_assumable_role_with_oidc.iam_role_name
}

output "grafana_cloudwatch_role_arn" {
  description = "ARN of the role Grafana assumes to read CloudWatch, for monitoring.awsDashboards.cloudwatch.assumeRoleArn. Created by this module already; it just had no way to be discovered."
  value       = aws_iam_role.grafana_cloudwatch.arn
}

output "grafana_role_arn" {
  description = "ARN of Grafana's own IRSA role, for the eks.amazonaws.com/role-arn annotation on the Grafana service account."
  value       = module.grafana_iam_assumable_role_with_oidc.iam_role_arn
}

output "grafana_role_name" {
  value = module.grafana_iam_assumable_role_with_oidc.iam_role_name
}
