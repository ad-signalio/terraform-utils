variable "project_id" {
  description = "GCP project ID the cluster is created in."
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
}

variable "region" {
  description = "Region for the cluster (and for the regional control plane / node pools)."
  type        = string
}

variable "regional" {
  description = "If true, a regional cluster (control plane + nodes across zones). If false, a zonal cluster — set zones to a single zone."
  type        = bool
  default     = true
}

variable "zones" {
  description = "Zones for the cluster. Required (single zone) when regional = false; optional for regional."
  type        = list(string)
  default     = []
}

variable "gateway_api_channel" {
  description = "Gateway API channel for the cluster. null = disabled. CHANNEL_STANDARD installs the Gateway API CRDs and the GKE managed GatewayClasses (gke-l7-global-external-managed, gke-l7-regional-external-managed, etc.)."
  type        = string
  default     = null
}

# --- Networking (from the tf-dt-vpc module outputs) ---
variable "network" {
  description = "VPC network name (tf-dt-vpc output network_name)."
  type        = string
}

variable "subnetwork" {
  description = "Node subnet name (tf-dt-vpc output subnet_name)."
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods (tf-dt-vpc output pods_range_name)."
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services (tf-dt-vpc output services_range_name)."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "Private control-plane /28 CIDR. Must not overlap the VPC subnet/pod/service ranges or any peered network. Pass the same value to tf-dt-vpc control_plane_cidr to open the webhook firewall."
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_endpoint" {
  description = "If true, the control-plane endpoint is private-only (no public endpoint) — requires VPN/bastion/IAP for kubectl/Terraform k8s providers to reach it. Default false keeps a public endpoint (lock it down with master_authorized_networks); nodes are private either way."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "CIDRs allowed to reach the (public) control-plane endpoint. List of objects { cidr_block, display_name }. Empty = no restriction."
  type        = list(object({ cidr_block = string, display_name = string }))
  default     = []
}

# --- Node pool ---
variable "machine_type" {
  description = "Machine type for the default node pool."
  type        = string
  default     = "e2-standard-4"
}

variable "min_node_count" {
  description = "Minimum nodes in the default pool (per zone for regional clusters)."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum nodes in the default pool (per zone for regional clusters)."
  type        = number
  default     = 3
}

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE)."
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Block Terraform from destroying the cluster. Default false for reference/test environments."
  type        = bool
  default     = false
}
