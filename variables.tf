variable "domain" {
  description = "The domain to create the SES identity for."
  type        = string
}

variable "zone_id" {
  type        = string
  description = "Route53 parent zone ID. If provided (not empty), the module will create Route53 DNS records used for verification"
  default     = ""
}


variable "custom_from_subdomain" {
  type        = list(string)
  description = "If provided the module will create a custom subdomain for the `From` address."
  default     = []
  nullable    = false

  validation {
    condition     = length(var.custom_from_subdomain) <= 1
    error_message = "Only one custom_from_subdomain is allowed."
  }

  validation {
    condition     = length(var.custom_from_subdomain) > 0 ? can(regex("^[a-zA-Z0-9-]+$", var.custom_from_subdomain[0])) : true
    error_message = "The custom_from_subdomain must be a valid subdomain."
  }
}

variable "iam_user_name" {
  description = "The name of the IAM user for SES."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "outgoing_email_address" {
  description = "Because we have not moved out of Amazon SES sandbox - we need to manually specify who we will send emails to."
  type        = string
}