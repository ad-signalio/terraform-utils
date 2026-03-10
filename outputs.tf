output "smtp_secret_name" {
  value = aws_secretsmanager_secret.ses_credentials.name
}