variable "tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default = {
    Environment = ""
    ManagedBy   = "Terraform"
  }
}

variable "oidc_provider_arn" {
  description = "The arn of the OIDC provider"
  type        = string
}

variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the ServiceAccount"
  type        = string
  default     = "default"
}

variable "k8s_service_account_name" {
  description = "Kubernetes ServiceAccount name to associate with the IAM role"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM role to create"
  type        = string
  default     = null
}

variable "attach_policy_arns" {
  description = "List of IAM policy ARNs to attach to the IAM role (managed policies)"
  type        = list(string)
  default     = []
}

variable "inline_role_policy" {
  description = "Optional JSON inline policy to attach to the role (as a single policy document). Leave null to skip."
  type        = string
  default     = null
}

variable "secret_naming_convention" {
  description = "Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager."
  type        = string
  default     = ""
}

variable "eks_cluster" {
  description = "The target EKS cluster object"
  type        = any
}
