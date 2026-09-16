variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to grant access to"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "default"
}

variable "kubernetes_service_account" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "domain_name" {
  description = "Names of domain name to associate with the load balancer if on route53"
  type        = string
}

variable "adsignal_org" {
  description = "The Ad Signal organization name, typically 'adsignal'"
  type        = string
  default     = "adsignal"
}

variable "allow_aws_secret_manager_access" {
  description = "Whether to allow access to AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "secret_naming_convention" {
  description = "Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager."
  type        = string
  default     = ""
}