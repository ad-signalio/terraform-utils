locals {
  # Configuration rationale (see README):
  # - vers=4.1: NFSv4.1 has locking built into the protocol (no NLM/statd),
  #   required for workloads that rely on POSIX file locking. The chart
  #   default is NFSv3 — do not remove this override.
  # - addr=<clusterIP>: minimal host OSes (Bottlerocket/EKS Auto Mode) ship no
  #   mount.nfs userspace helper, so the in-tree NFS mount needs the resolved
  #   address passed explicitly. Harmless on hosts that do ship it (GKE COS).
  #   This is why the service clusterIP must be pinned.
  mount_options = concat(
    [
      "vers=4.1",
      "addr=${var.service_cluster_ip}",
    ],
    var.extra_mount_options,
  )

  base_values = {
    persistence = merge(
      {
        enabled = true
        size    = var.backing_disk_size
      },
      # null = omit, letting the cluster's default StorageClass back the
      # NFS server's disk (EBS on EKS, PD on GKE, local-path on bare metal).
      var.backing_storage_class == null ? {} : { storageClass = var.backing_storage_class },
    )

    service = {
      clusterIP = var.service_cluster_ip
    }

    storageClass = {
      create        = true
      name          = var.storage_class_name
      reclaimPolicy = var.reclaim_policy
      parameters = {
        # Provisioned exports get a setgid group dir owned by this GID, so
        # nonroot pods running with it (match uses 65532) can read/write.
        gid = tostring(var.export_gid)
      }
      mountOptions = local.mount_options
    }

    resources = var.resources
  }
}

resource "helm_release" "nfs_provisioner" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  repository = "https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/"
  chart      = "nfs-server-provisioner"
  version    = var.chart_version
  namespace  = var.namespace

  create_namespace = true
  cleanup_on_fail  = true

  values = concat(var.values, [
    yamlencode(local.base_values),
    yamlencode(var.settings),
  ])
}
