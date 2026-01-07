output "rds_pg_secret_name" {
  value = aws_secretsmanager_secret.rds_pg[0].name
}