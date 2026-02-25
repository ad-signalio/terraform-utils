output "role_arn" {
  value = module.iam_assumable_role_with_oidc.iam_role_arn
}

output "role_name" {
  value = module.iam_assumable_role_with_oidc.iam_role_name
}
