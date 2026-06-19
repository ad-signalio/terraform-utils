variable "project_id" {
  description = "GCP project ID the Cloud SQL instance is created in."
  type        = string
}

variable "env_name" {
  description = "Environment name; base for the instance and secret names."
  type        = string
}

variable "region" {
  description = "Region for the Cloud SQL instance."
  type        = string
}

variable "zone" {
  description = "Preferred zone for a ZONAL instance (optional)."
  type        = string
  default     = null
}

variable "database_version" {
  description = "Cloud SQL PostgreSQL version (e.g. POSTGRES_16)."
  type        = string
  default     = "POSTGRES_16"
}

variable "edition" {
  description = "Cloud SQL edition. ENTERPRISE matches the db-custom-N-M / db-highmem tiers in the sizing scheme; ENTERPRISE_PLUS requires db-perf-optimized-* tiers."
  type        = string
  default     = "ENTERPRISE"
}

variable "tier" {
  description = "Machine tier (db-custom-N-M). Set per sizing profile in tfvars (small: db-custom-4-15360, medium: db-custom-8-30720, large: db-highmem-16)."
  type        = string
  default     = "db-custom-2-7680"
}

variable "availability_type" {
  description = "ZONAL (single zone) or REGIONAL (HA)."
  type        = string
  default     = "ZONAL"
}

variable "disk_size" {
  description = "Data disk size in GB."
  type        = number
  default     = 20
}

variable "disk_autoresize" {
  description = "Allow the data disk to grow automatically."
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Application database name."
  type        = string
  default     = "match"
}

variable "db_user" {
  description = "Application database user name."
  type        = string
  default     = "match"
}

variable "database_flags" {
  description = "List of Cloud SQL database flags ({ name, value })."
  type        = list(object({ name = string, value = string }))
  default     = []
}

# --- Private Service Access networking (from the tf-dt-vpc module) ---
variable "private_network" {
  description = "VPC network self-link/id for the private IP (tf-dt-vpc output network_id). Private IP only — ipv4_enabled is forced false."
  type        = string
}

variable "allocated_ip_range" {
  description = "Name of the reserved Private Service Access range to draw the private IP from (tf-dt-vpc output psa_range_name). null lets Google pick any PSA range."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Protect the instance from deletion (both the Terraform lifecycle guard and the GCP instance setting). Default false for reference/test environments."
  type        = bool
  default     = false
}

variable "random_instance_name" {
  description = "Append a random suffix to the instance name. Recommended: Cloud SQL instance names can't be reused for ~1 week after deletion, which bites repeated create/destroy in test envs."
  type        = bool
  default     = true
}

variable "create_secret" {
  description = "Store connection details (host, port, db, user, password) in GCP Secret Manager."
  type        = bool
  default     = true
}
