output "namespace" {
  description = "Namespace cert-manager is installed into."
  value       = var.enabled ? var.namespace : null
}
