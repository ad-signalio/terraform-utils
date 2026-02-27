variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "secret_naming_convention" {
  description = "Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager."
  type        = string
  default     = ""
}

variable "owning_user_email" {
  description = "Email of the Admin user to access Match."
  type        = strings
}