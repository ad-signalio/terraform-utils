variable "env_use" {
  description = "The environment type (e.g., prod, test, uat, sbox)"
  type        = string
  validation {
    condition     = contains(["prod", "test", "uat", "sbox", "test", "demo"], var.env_use)
    error_message = "env_use must be one of 'prod', 'test', 'uat', 'sbox', 'test', 'demo'"
  }
}

variable "env_id" {
  description = "The unique ID such as customer or use for an environment name, eg bigcorp, mediaorg, adsignal or snicket. Limited to 12 characters."
  type        = string
  validation {
    condition     = length(var.env_id) < 10
    error_message = "env_id must be 10 characters or fewer."
  }
}

variable "env_additional_id" {
  description = "An OPTIONAL additional identifier to be appended after the first Identifier - should mostly not be used. Limited to 5 characters."
  type        = string
  validation {
    condition     = length(var.env_additional_id) < 5
    error_message = "env_additional_id must be 5 characters or fewer."
  }
  default = ""
}

variable "env_region" {
  description = "The region (e.g., us1, eu1, ap1)"
  type        = string
  validation {
    condition     = contains(["us1", "eu1", ], var.env_region)
    error_message = "env_region must be one of 'us1', 'eu1'"
  }
}

locals {
  name = join("-", compact([var.env_use, var.env_id, var.env_additional_id, var.env_region]))
  tags = {
    product     = "match-${var.env_id}"
    product-use = local.name
    as-env-use  = var.env_use
    as-cust-id  = var.env_id
  }
}

output "env_name" {
  description = "Standardized name for resources"
  value       = local.name
}

output "tags" {
  description = "Standardized tags for resources"
  value       = local.tags
}
