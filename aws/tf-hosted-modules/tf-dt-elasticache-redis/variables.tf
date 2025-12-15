variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "private_subnets" {
  description = "A list of private subnet IDs"
  type        = any
}

variable "az" {
  description = "The single availability zone to use"
  type        = string
}

variable "vpc" {
  description = "The VPC configuration"
  type        = any
}

variable "k8s_namespace" {
  description = "The Kubernetes namespace to deploy resources into"
  type        = string
  default     = "match"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "secret_naming_convention" {
  description = "Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager."
  type        = string
  default     = ""
}

variable "create_aws_secret" {
  description = "Create a secret with the rds config to AWS Secrets Manager"
  type        = bool
  default     = true
}