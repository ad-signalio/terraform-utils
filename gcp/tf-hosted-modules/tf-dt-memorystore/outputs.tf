output "host" {
  description = "Memorystore private IP (Redis host)."
  value       = module.redis.host
}

output "port" {
  description = "Redis port."
  value       = module.redis.port
}

output "secret_id" {
  description = "Secret Manager secret with the Redis connection details (null if create_secret = false)."
  value       = var.create_secret ? google_secret_manager_secret.connection[0].secret_id : null
}
