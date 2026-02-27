output "api_secret_name" {
  description = "Name of the AWS Secrets Manager secret for API credentials."
  value       = aws_secretsmanager_secret.api_secrets.name
}

output "user_secret_name" {
  value       = aws_secretsmanager_secret.user_password.name
  description = "Name of the AWS Secrets Manager secret for user credentials."
}