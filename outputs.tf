output "private_ip_address" {
  description = "Private IP of the Cloud SQL instance (pods connect here directly)."
  value       = module.postgresql.private_ip_address
}

output "instance_connection_name" {
  description = "Cloud SQL connection name (project:region:instance)."
  value       = module.postgresql.instance_connection_name
}

output "instance_name" {
  description = "Cloud SQL instance name (includes the random suffix if enabled)."
  value       = module.postgresql.instance_name
}

output "db_name" {
  description = "Application database name."
  value       = var.db_name
}

output "secret_id" {
  description = "Secret Manager secret holding the connection details (null if create_secret = false)."
  value       = var.create_secret ? google_secret_manager_secret.connection[0].secret_id : null
}
