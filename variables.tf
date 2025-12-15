variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
  default     = null
}

variable "use_name_prefix" {
  description = "Determines whether the IAM role/policy name (`name`/`policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "The domain name of the Route53 hosted zone"
  type        = string
}
