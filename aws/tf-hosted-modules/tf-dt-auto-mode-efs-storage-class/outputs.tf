output "storage_class_name" {
  description = "Name of the EBS StorageClass. This is the one that works under EKS Auto Mode -- the in-tree gp2 class does not -- so it is what Prometheus, Grafana and any other PVC in the release should use."
  value       = kubernetes_storage_class_v1.auto_ebs_gp2.metadata[0].name
}
