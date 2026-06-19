output "bucket_name" {
  description = "Name of the active-storage bucket (set as the GCS service bucket in config/storage.yml)."
  value       = google_storage_bucket.primary.name
}

output "bucket_url" {
  description = "gs:// URL of the bucket."
  value       = google_storage_bucket.primary.url
}

output "bucket_self_link" {
  description = "Self link of the bucket."
  value       = google_storage_bucket.primary.self_link
}

output "hmac_secret_name" {
  description = "Secret Manager secret holding the GCS HMAC {access_id, secret} for S3-interop. null when create_hmac_key=false. ESO syncs this into the cluster's s3 secret."
  value       = var.create_hmac_key ? google_secret_manager_secret.hmac[0].secret_id : null
}
