variable "project_id" {
  description = "GCP project ID the VPC resources are created in (required by the upstream network module)."
  type        = string
}

variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1). Used as the base name for VPC resources."
  type        = string
}

variable "region" {
  description = "Region for the (regional) subnet, Cloud Router and Cloud NAT."
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR of the GKE node subnet."
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary range for GKE pods (VPC-native cluster). Must be large — one /24 per node by default."
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_cidr" {
  description = "Secondary range for GKE services (VPC-native cluster)."
  type        = string
  default     = "10.8.0.0/20"
}

variable "psa_prefix_length" {
  description = "Prefix length of the Private Service Access range reserved for Google-managed services (Cloud SQL, Memorystore private IP)."
  type        = number
  default     = 16
}

variable "control_plane_cidr" {
  description = "GKE private control-plane CIDR (master_ipv4_cidr). When set, a firewall rule allows it to reach nodes for webhooks/metrics. Leave empty to skip."
  type        = string
  default     = ""
}

variable "enable_iap_ssh" {
  description = "Allow SSH from Google's IAP TCP-forwarding range (35.235.240.0/20) to instances in the VPC."
  type        = bool
  default     = false
}
