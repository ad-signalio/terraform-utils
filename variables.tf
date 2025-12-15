variable "tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default = {
    Environment = ""
    ManagedBy   = "Terraform"
  }
}

variable "env_name" {
  description = "The environment name."
  type        = string
}

variable "service_account_role_name" {
  description = "The name of the IAM role to attach the policy to"
  type        = string
}
