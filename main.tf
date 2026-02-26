## create secrets for
## 1. api-secrets
## 2. user password for the system

resource "random_password" "secret_key_base" {
  length  = 128
  special = false
}

resource "random_password" "api_secret_key_base" {
  length  = 128
  special = false
}

resource "random_id" "ingest_credential_encryption_key" {
  byte_length = 32
}


resource "aws_secretsmanager_secret" "api_secrets" {
  name_prefix = "${var.secret_naming_convention}-api-secrets"
  description = "Rails secrets for ${var.env_name}"

  recovery_window_in_days = 0

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "api_secrets_version" {
  secret_id = aws_secretsmanager_secret.api_secrets.id
  secret_string = jsonencode({
    ingest_credential_encryption_key = random_id.ingest_credential_encryption_key.hex
    secret_key_base                  = random_password.secret_key_base.result
    api_secret_key_base              = random_password.api_secret_key_base.result
  })
}

resource "random_password" "user_password" {
  length      = 20
  special     = true
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
}

resource "aws_secretsmanager_secret" "user_password" {
  name_prefix             = "${var.secret_naming_convention}-user-password"
  description             = "Password for ${var.env_name} initial user."
  recovery_window_in_days = 0

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "user_password_version" {
  secret_id = aws_secretsmanager_secret.user_password.id
  secret_string = jsonencode({
    password = random_password.user_password.result
  })
}