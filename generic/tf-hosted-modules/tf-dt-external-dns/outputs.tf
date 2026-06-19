output "namespace" {
  description = "Namespace external-dns is installed in."
  value       = var.namespace
}

output "release_name" {
  description = "Name of the external-dns Helm release (null when disabled)."
  value       = var.enabled ? helm_release.external_dns[0].name : null
}
