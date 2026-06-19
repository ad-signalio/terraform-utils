variable "project_id" {
  type        = string
  description = "GCP project ID."
}

variable "name" {
  type        = string
  description = "Name of the Filestore instance."
}

variable "location" {
  type        = string
  description = "Zone for the Filestore instance (BASIC tiers are zonal, e.g. us-central1-a)."
}

variable "tier" {
  type        = string
  default     = "BASIC_HDD"
  description = "Filestore service tier. BASIC_HDD is the cheapest production tier (1 TiB minimum)."
  validation {
    condition     = contains(["BASIC_HDD", "BASIC_SSD", "ZONAL", "REGIONAL", "ENTERPRISE"], var.tier)
    error_message = "tier must be one of BASIC_HDD, BASIC_SSD, ZONAL, REGIONAL, ENTERPRISE."
  }
}

variable "capacity_gb" {
  type        = number
  default     = 1024
  description = "Share capacity in GiB. BASIC_HDD minimum is 1024 (1 TiB)."
  validation {
    condition     = var.capacity_gb >= 1024
    error_message = "capacity_gb must be at least 1024 (the BASIC_HDD minimum)."
  }
}

variable "share_name" {
  type        = string
  default     = "share1"
  description = "Name of the NFS file share/export (alphanumeric + underscores, max 16 chars)."
}

variable "network" {
  type        = string
  description = "Name (or self-link) of the authorized VPC network the instance is reachable on."
}

variable "connect_mode" {
  type        = string
  default     = "DIRECT_PEERING"
  description = "How the instance connects to the VPC: DIRECT_PEERING (Filestore manages its own peering) or PRIVATE_SERVICE_ACCESS (reuses the VPC's PSA range — set reserved_ip_range)."
  validation {
    condition     = contains(["DIRECT_PEERING", "PRIVATE_SERVICE_ACCESS"], var.connect_mode)
    error_message = "connect_mode must be DIRECT_PEERING or PRIVATE_SERVICE_ACCESS."
  }
}

variable "reserved_ip_range" {
  type        = string
  default     = null
  description = "Reserved IP range. For DIRECT_PEERING an optional /29 CIDR; for PRIVATE_SERVICE_ACCESS the name of the allocated PSA range (e.g. module.vpc.psa_range_name)."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels applied to the Filestore instance."
}

variable "deletion_protection_enabled" {
  type        = bool
  default     = true
  description = "Protect the instance from accidental deletion. Disable for throwaway/test instances."
}

# --- Kubernetes wiring (static PV/PVC via the Filestore CSI driver) ---

variable "create_kubernetes_resources" {
  type        = bool
  default     = true
  description = "Create the static PersistentVolume + PersistentVolumeClaim bound to the instance. Set false to provision the instance only and wire k8s separately. Requires the GKE Filestore CSI driver addon (filestore.csi.storage.gke.io)."
}

variable "pvc_name" {
  type        = string
  default     = "match-shared-storage"
  description = "Name of the RWX PVC (matches the helm-match storage.sharedStorage.claimName default)."
}

variable "namespace" {
  type        = string
  default     = "match"
  description = "Namespace for the PVC."
}

variable "pv_name" {
  type        = string
  default     = null
  description = "Name of the static PersistentVolume. Defaults to \"<name>-pv\"."
}

variable "storage_class_name" {
  type        = string
  default     = ""
  description = "storageClassName for the static PV + PVC. Empty string = static binding (no dynamic provisioner)."
}
