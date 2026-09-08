output "node_class_name" {
  description = "Name of the NodeClass the NodePools reference"
  value       = var.enabled ? var.name : null
}

output "node_pool_names" {
  description = "Names of the NodePools created"
  value = compact([
    var.enabled && var.create_system_node_pool ? "system" : "",
    var.enabled && var.create_general_purpose_node_pool ? "general-purpose" : "",
  ])
}
