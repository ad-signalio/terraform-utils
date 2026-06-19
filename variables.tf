variable "project_id" {
  description = "GCP project ID the Memorystore instance is created in."
  type        = string
}

variable "env_name" {
  description = "Environment name; base for the instance and secret names."
  type        = string
}

variable "region" {
  description = "Region for the Memorystore instance."
  type        = string
}

variable "tier" {
  description = "Service tier: BASIC (single node) or STANDARD_HA (replicated). Set per sizing profile in tfvars."
  type        = string
  default     = "BASIC"
}

variable "memory_size_gb" {
  description = "Redis memory size in GiB."
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "Redis version (e.g. REDIS_7_2)."
  type        = string
  default     = "REDIS_7_2"
}

variable "auth_enabled" {
  description = "Enable Redis AUTH (generates an auth string)."
  type        = bool
  default     = true
}

variable "transit_encryption_mode" {
  description = "In-transit encryption: DISABLED or SERVER_AUTHENTICATION."
  type        = string
  default     = "DISABLED"
}

# --- Private connectivity (from the tf-dt-vpc module) ---
variable "network" {
  description = "VPC network self-link for authorized_network (tf-dt-vpc output network_self_link — use the self-link, not network_id; see tf-dt-vpc PSA note)."
  type        = string
}

variable "reserved_ip_range" {
  description = "Name of the reserved Private Service Access range (tf-dt-vpc output psa_range_name) for PRIVATE_SERVICE_ACCESS connect mode. null lets Google pick."
  type        = string
  default     = null
}

variable "create_secret" {
  description = "Store the Redis connection URL/details in GCP Secret Manager."
  type        = bool
  default     = true
}
