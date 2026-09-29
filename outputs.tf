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
