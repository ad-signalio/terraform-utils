resource "kubernetes_storage_class_v1" "match_shared_storage" {
  metadata {
    name = "match-shared-storage"
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "755"
  }

  mount_options = ["iam"]
}

resource "kubernetes_persistent_volume" "shared_storage" {

  metadata {
    name = var.storage_shared_storage_claim_name
    labels = {
      type = "shared-storage"
    }
  }

  spec {
    capacity = {
      storage = var.storage_shared_storage_size
    }
    volume_mode                      = "Filesystem"
    access_modes                     = ["ReadWriteMany"]
    storage_class_name               = var.storage_shared_storage_claim_name
    persistent_volume_reclaim_policy = "Delete"
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = aws_efs_file_system.eks.id
      }
    }
    mount_options = ["iam"]
  }
}
