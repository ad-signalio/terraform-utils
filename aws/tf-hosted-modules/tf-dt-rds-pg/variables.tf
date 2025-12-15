variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the RDS instance"
  type        = list(string)
}

variable "engine_version" {
  description = "The Postgres database engine version"
  type        = string
  default     = "17.4"
}

variable "parameter_group_family" {
  description = "The Postgres parameter group family"
  type        = string
  default     = "postgres17"
}

variable "major_engine_version" {
  description = "The major version of the Postgres database engine option group"
  type        = string
  default     = "17.4"
}

variable "instance_class" {
  description = "The instance class to use for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in GBs"
  type        = number
  default     = 50
}

variable "max_allocated_storage" {
  description = "The maximume allocated storage in GBs"
  type        = number
  default     = 150
}

variable "enhanced_monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected default 0 disables"
  type        = number
  default     = 0
}

variable "maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created if automated backups are enabled"
  type        = string
  default     = "03:00-06:00"
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security group IDs to associate"
  type        = list(string)
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 30
}

variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "The number of days to retain Performance Insights data"
  type        = number
  default     = 7
}

variable "parameters" {
  description = "A list of DB parameter group parameters to apply"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "k8s_namespace" {
  description = "The Kubernetes namespace to create the secret in"
  type        = string
}

variable "deletion_protection" {
  description = "Whether to allow the RDS instance to be destroyed"
  type        = bool
  default     = false
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