variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "dockerconfig_json" {
  description = "Base64 encoded dockerconfigjson for pulling images from private registries"
  type        = string
  default     = "{}"
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "match"
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
  default     = null
}

variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "domain_name" {
  description = "Names of domain name to associate with the load balancer if on route53"
  type        = string
}

variable "root_domain_name" {
  description = "Root domain name for certificate lookup"
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

variable "github_token" {
  description = "GitHub token for authentication"
  type        = string
  sensitive   = true
}

variable "secret_store_role_arn" {
  description = "ARN of the IAM Role for Secret Store"
  type        = string
}

variable "rds_pg_secret_name" {
  description = "Name of the AWS Secrets Manager secret for RDS Postgres."
  type        = string
}

variable "service_account_role_name" {
  description = "The name of the IAM role for service account"
  type        = string
}

variable "tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default = {
    Environment = ""
    ManagedBy   = "Terraform"
  }
}

variable "environment_size" {
  description = "Environment size: small, medium, or large"
  type        = string
  validation {
    condition     = contains(["small", "medium", "large"], var.environment_size)
    error_message = "Must be one of: small, medium, large"
  }
}

variable "smtp_secret_name" {
  description = "Name of the AWS Secrets Manager secret for SMTP."
  type        = string
}

variable "organisation_name" {
  description = "Name of the initial Org to use match"
  type        = string
}

variable "api_secret_name" {
  description = "Name of the AWS Secrets Manager secret for API credentials."
  type        = string
}

variable "user_secret_name" {
  description = "Name of the AWS Secrets Manager secret for user credentials."
  type        = string
}

variable "owning_user_email" {
  description = "Email of the Admin user to access Match."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.owning_user_email))
    error_message = "owning_user_email must be a valid email address."
  }
}