
variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "Names of domain name to associate with the load balancer if on route53"
  type        = string
}

variable "eks_cluster" {
  description = "The target EKS cluster object"
  type        = any
}

variable "eks_cluster_auth" {
  description = "The target EKS cluster auth object"
  type        = any
}

variable "vpc" {
  description = "The VPC configuration"
  type        = any
}

variable "use_name_prefix" {
  description = "Determines whether the IAM role/policy name (`name`/`policy_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "install_helm_charts" {
  description = "Whether to install helm charts."
  type        = bool
  default     = true
}
