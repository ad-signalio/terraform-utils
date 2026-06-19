output "storage_class_name" {
  description = "Name of the RWX StorageClass created for consumers (use as storage.sharedStorage.storageClassName in helm-match values)."
  value       = var.enabled ? var.storage_class_name : null
}

output "service_cluster_ip" {
  description = "Pinned ClusterIP of the NFS server Service."
  value       = var.enabled ? var.service_cluster_ip : null
}

output "namespace" {
  description = "Namespace the NFS provisioner is installed into."
  value       = var.enabled ? var.namespace : null
}
