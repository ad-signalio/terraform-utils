variable "enabled" {
  description = "Whether to deploy the NFS provisioner."
  type        = bool
  default     = true
}

variable "release_name" {
  description = "Helm release name."
  type        = string
  default     = "nfs-provisioner"
}

variable "chart_version" {
  description = "Version of the kubernetes-sigs nfs-server-provisioner Helm chart."
  type        = string
  default     = "1.8.0"
}

variable "namespace" {
  description = "Namespace to install the NFS provisioner into (created if absent)."
  type        = string
  default     = "nfs-provisioner"
}

variable "service_cluster_ip" {
  description = <<-EOT
    ClusterIP to pin the NFS server Service to. Must be a free IP inside the
    cluster's Service CIDR. Required because the StorageClass mountOptions
    reference it via addr= — needed on minimal host OSes (e.g. Bottlerocket)
    that ship no mount.nfs userspace helper.
  EOT
  type        = string

  validation {
    condition     = can(cidrnetmask("${var.service_cluster_ip}/32"))
    error_message = "service_cluster_ip must be a valid IPv4 address inside the cluster's Service CIDR."
  }
}

variable "storage_class_name" {
  description = "Name of the RWX StorageClass the provisioner creates for consumers."
  type        = string
  default     = "match-shared-storage-nfs"
}

variable "backing_storage_class" {
  description = "RWO StorageClass backing the NFS server's disk (e.g. auto-ebs-gp2 on EKS Auto Mode, standard-rwo on GKE). null uses the cluster default."
  type        = string
  default     = null
}

variable "backing_disk_size" {
  description = "Size of the backing disk for the NFS server."
  type        = string
  default     = "200Gi"
}

variable "export_gid" {
  description = "GID applied to provisioned exports (setgid group dir). Pods running with this group can read/write. Match pods run as 65532 (nonroot)."
  type        = number
  default     = 65532
}

variable "reclaim_policy" {
  description = "ReclaimPolicy for the consumer StorageClass (Delete or Retain)."
  type        = string
  default     = "Delete"

  validation {
    condition     = contains(["Delete", "Retain"], var.reclaim_policy)
    error_message = "reclaim_policy must be Delete or Retain."
  }
}

variable "extra_mount_options" {
  description = "Additional NFS mount options appended after vers=4.1 and addr=."
  type        = list(string)
  default     = []
}

variable "resources" {
  description = "Resource requests/limits for the NFS server pod."
  type        = any
  default = {
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
    limits = {
      memory = "512Mi"
    }
  }
}

variable "settings" {
  description = "Additional settings to pass to the Helm chart (merged last, overrides module defaults)."
  type        = map(any)
  default     = {}
}

variable "values" {
  description = "List of values in raw YAML format to pass to the helm release."
  type        = list(string)
  default     = []
}
