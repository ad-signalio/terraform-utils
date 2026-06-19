output "cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.name
}

output "location" {
  description = "Cluster location (region or zone)."
  value       = module.gke.location
}

output "cluster_endpoint" {
  description = "Cluster API endpoint (for the Terraform kubernetes/helm providers)."
  value       = module.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 cluster CA certificate (for the Terraform kubernetes/helm providers)."
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "node_service_account" {
  description = "Email of the dedicated node service account."
  value       = module.gke.service_account
}

output "workload_identity_pool" {
  description = "Workload Identity pool (<project>.svc.id.goog)."
  value       = module.gke.identity_namespace
}
