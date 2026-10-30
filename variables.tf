variable "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "github_token" {
  description = "GitHub token for authentication"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}

variable "domain_name" {
  description = "Domain that the app is hosted, dns, app settings, etc."
  type        = string
}

variable "secret_store_role_arn" {
  description = "ARN of the IAM Role for Secret Store"
  type        = string
}

variable "rds_pg_secret_name" {
  description = "Name of the AWS Secrets Manager secret for RDS Postgres."
  type        = string
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
}