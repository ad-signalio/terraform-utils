resource "kubernetes_storage_class_v1" "match_shared_storage" {
  metadata {
    name = "match-shared-storage"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "755"
    gid              = var.appuser_id
    uid              = var.appuser_id
  }

  mount_options = ["iam"]
}

