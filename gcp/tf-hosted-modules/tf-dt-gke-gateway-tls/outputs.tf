output "gateway_name" {
  description = "Name of the Gateway resource. Use as the HTTPRoute parentRefs[].name."
  value       = var.gateway_name
}

output "namespace" {
  description = "Namespace the Gateway + Certificate are in."
  value       = var.namespace
}

output "static_ip_address" {
  description = "The reserved global external IP, or null when not created. Point DNS here."
  value       = local.create_ip ? google_compute_global_address.gateway[0].address : null
}

output "static_ip_name" {
  description = "Name of the reserved global address, or null when not created."
  value       = local.create_ip ? google_compute_global_address.gateway[0].name : null
}

output "tls_secret_name" {
  description = "Secret holding the issued cert/key (consumed by the Gateway HTTPS listener)."
  value       = var.tls_secret_name
}

output "cluster_issuer_name" {
  description = "Name of the ClusterIssuer created when enable_tls."
  value       = var.cluster_issuer_name
}
