variable "project_id" {
  description = "GCP project ID the secrets are created in."
  type        = string
}

variable "env_name" {
  description = "Environment name; secrets are named <env_name>-api-secrets and <env_name>-user-password."
  type        = string
}

variable "owning_user_email" {
  description = "Optional. If set, included as the username in the owning-user secret alongside the generated password."
  type        = string
  default     = ""
}
