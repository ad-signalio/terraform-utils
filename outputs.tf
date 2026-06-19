output "api_secret_name" {
  description = "Secret Manager secret_id holding the Rails api-secrets (for the ESO ExternalSecret)."
  value       = google_secret_manager_secret.api_secrets.secret_id
}

output "user_secret_name" {
  description = "Secret Manager secret_id holding the owning-user password (for the ESO ExternalSecret)."
  value       = google_secret_manager_secret.user_password.secret_id
}
