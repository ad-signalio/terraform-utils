output "gcp_service_account_email" {
  description = "Email of the GSA. Grant this resource-scoped access (e.g. pass to tf-dt-gcs-active-storage service_account_email for the bucket grant)."
  value       = module.workload_identity.gcp_service_account_email
}

output "gcp_service_account_fqn" {
  description = "Fully-qualified GSA name (projects/.../serviceAccounts/...)."
  value       = module.workload_identity.gcp_service_account_fqn
}

output "k8s_service_account_name" {
  description = "Name of the Kubernetes ServiceAccount bound to the GSA."
  value       = module.workload_identity.k8s_service_account_name
}
