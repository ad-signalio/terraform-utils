variable "tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default = {
    Environment = ""
    ManagedBy   = "Terraform"
  }
}

variable "oidc_url" {
  description = "The URL of the OIDC provider"
  type        = string
}
