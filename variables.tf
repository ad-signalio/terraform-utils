variable "project_id" {
  description = "GCP project ID the bucket is created in."
  type        = string
}

variable "env_name" {
  description = "Environment name; the bucket is named <env_name>-primary."
  type        = string
}

variable "location" {
  description = "Bucket location — a region (e.g. us-central1, co-located with GKE to avoid egress) or a multi-region (e.g. US)."
  type        = string
  default     = "US"
}

variable "app_url" {
  description = "Allowed CORS origins for Active Storage direct uploads (list of URLs). Mirrors the S3 CORS policy. Empty disables the CORS rule."
  type        = list(string)
  default     = []
}

variable "versioning" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even if it contains objects. Default false; set true only for throwaway test envs."
  type        = bool
  default     = false
}

variable "kms_key_name" {
  description = "Customer-managed KMS key for encryption at rest. null uses Google-managed keys (still encrypted at rest)."
  type        = string
  default     = null
}

variable "service_account_email" {
  description = "App GSA (from Workload Identity) to grant roles/storage.objectUser on the bucket. Empty skips the grant (set once the GSA exists)."
  type        = string
  default     = ""
}

variable "create_hmac_key" {
  description = "Create an HMAC key for service_account_email and store {access_id, secret} in Secret Manager (<env_name>-gcs-hmac), for S3-interoperability Active Storage. Requires service_account_email. Default false."
  type        = bool
  default     = false
}
