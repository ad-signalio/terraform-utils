output "network_id" {
  description = "VPC network ID (for use by the GKE and Cloud SQL modules)."
  value       = module.vpc.network_id
}

output "network_name" {
  description = "VPC network name."
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "VPC network self link."
  value       = module.vpc.network_self_link
}

output "subnet_name" {
  description = "Node subnet name (needed by the GKE module)."
  value       = local.subnet_name
}

output "subnet_id" {
  description = "Node subnet ID."
  value       = module.vpc.subnets_ids[0]
}

output "subnet_self_link" {
  description = "Node subnet self link."
  value       = module.vpc.subnets_self_links[0]
}

output "pods_range_name" {
  description = "Name of the secondary range for GKE pods (VPC-native cluster)."
  value       = local.pods_range_name
}

output "services_range_name" {
  description = "Name of the secondary range for GKE services (VPC-native cluster)."
  value       = local.services_range_name
}

output "psa_range_name" {
  description = "Name of the reserved Private Service Access range."
  value       = google_compute_global_address.psa.name
}

output "private_vpc_connection" {
  description = "Service networking connection ID (depend on this from Cloud SQL / Memorystore to ensure peering exists first)."
  value       = google_service_networking_connection.psa.id
}
