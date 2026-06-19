output "instance_name" {
  description = "Name of the Filestore instance."
  value       = google_filestore_instance.this.name
}

output "ip_address" {
  description = "The IP address the NFS share is reachable on."
  value       = google_filestore_instance.this.networks[0].ip_addresses[0]
}

output "share_name" {
  description = "Name of the NFS file share/export."
  value       = var.share_name
}

output "pv_name" {
  description = "Name of the static PersistentVolume (null when create_kubernetes_resources = false)."
  value       = var.create_kubernetes_resources ? kubernetes_persistent_volume_v1.this[0].metadata[0].name : null
}

output "pvc_name" {
  description = "Name of the RWX PersistentVolumeClaim — use as storage.sharedStorage.claimName (null when create_kubernetes_resources = false)."
  value       = var.create_kubernetes_resources ? var.pvc_name : null
}
