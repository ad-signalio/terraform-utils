output "namespace" {
  description = "Namespace the External Secrets Operator is installed into."
  value       = var.enabled ? var.namespace : null
}
