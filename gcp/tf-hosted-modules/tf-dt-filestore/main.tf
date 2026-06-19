# Managed GCP Filestore for production RWX shared storage — the SLA-backed
# alternative to the in-cluster NFS provisioner (tf-dt-nfs-provisioner), which is
# single-pod and only suitable for internal/test/bare-metal tiers.
#
# Creates a Filestore instance + a STATIC PersistentVolume/Claim bound to its
# export via the GKE Filestore CSI driver. Static (not dynamic) because the
# instance is pre-provisioned here — dynamic provisioning would mint a new 1 TiB
# instance per PVC. The helm-match chart then consumes it via
# storage.sharedStorage.claimName (default "match-shared-storage").
#
# NOTE (cost): BASIC_HDD has a 1 TiB minimum (~$200/mo), so only stand this up for
# real production demand. NOTE (prereq): the cluster needs the Filestore CSI
# driver addon enabled (filestore.csi.storage.gke.io). NOTE (permissions): pods
# run as nonroot (65532); set podSecurityContext.fsGroup: 65532 so the CSI driver
# chowns the mount — Filestore has no per-export gid knob like the NFS provisioner.

locals {
  pv_name = coalesce(var.pv_name, "${var.name}-pv")
}

resource "google_filestore_instance" "this" {
  project  = var.project_id
  name     = var.name
  location = var.location
  tier     = var.tier
  labels   = var.labels

  deletion_protection_enabled = var.deletion_protection_enabled

  file_shares {
    name        = var.share_name
    capacity_gb = var.capacity_gb
  }

  networks {
    network           = var.network
    modes             = ["MODE_IPV4"]
    connect_mode      = var.connect_mode
    reserved_ip_range = var.reserved_ip_range
  }
}

# Static PV pointing at the pre-provisioned instance via the Filestore CSI driver.
resource "kubernetes_persistent_volume_v1" "this" {
  count = var.create_kubernetes_resources ? 1 : 0

  metadata {
    name = local.pv_name
  }
  spec {
    capacity = {
      storage = "${var.capacity_gb}Gi"
    }
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    persistent_volume_source {
      csi {
        driver        = "filestore.csi.storage.gke.io"
        volume_handle = "modeInstance/${var.location}/${var.name}/${var.share_name}"
        read_only     = false
        volume_attributes = {
          ip     = google_filestore_instance.this.networks[0].ip_addresses[0]
          volume = var.share_name
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "this" {
  count = var.create_kubernetes_resources ? 1 : 0

  metadata {
    name      = var.pvc_name
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    volume_name        = kubernetes_persistent_volume_v1.this[0].metadata[0].name
    resources {
      requests = {
        storage = "${var.capacity_gb}Gi"
      }
    }
  }
}
