output "gateway_name" {
  description = "Name of the Gateway resource. Use as the HTTPRoute parentRefs[].name."
  value       = var.gateway_name
}

output "namespace" {
  description = "Namespace the Gateway is in."
  value       = var.namespace
}

output "static_ip_address" {
  description = "The reserved global external IP address, or null when not created. Point DNS here."
  value       = local.create_ip ? google_compute_global_address.gateway[0].address : null
}

output "static_ip_name" {
  description = "Name of the reserved global address, or null when not created."
  value       = local.create_ip ? google_compute_global_address.gateway[0].name : null
}
