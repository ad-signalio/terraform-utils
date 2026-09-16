output "storage_class_name" {
  description = "Name of the EFS-backed StorageClass, for the match chart's storage.sharedStorage.storageClassName."
  value       = kubernetes_storage_class_v1.match_shared_storage.metadata[0].name
}
