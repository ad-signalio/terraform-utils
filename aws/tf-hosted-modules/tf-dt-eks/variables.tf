variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "node_count" {
  description = "Number of compute nodes for the EKS cluster"
  type        = number
}

variable "node_instance_type" {
  description = "Instance type for EKS compute nodes"
  type        = string
}

variable "admin_access_sso_permission_set_names" {
  description = "A list of AWS SSO permission set names (NOT full ARNs) that exist in the account that will have admin access to the EKS cluster eg 'Infra'"
  type        = list(string)
  default     = []
}

variable "admin_access_role_names" {
  description = "A list of IAM role names (NOT full ARNs) that exist in the account that will have admin access to the EKS cluster"
  type        = list(string)
  default     = []

}

variable "extra_access_entries" {
  description = "Map of extra Cluster access entries. See terraform-aws-modules/eks/aws for details."
  type        = map(any)
  default     = {}
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  default     = {}
  type        = map(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "subnets_in_az" {
  description = "A list of subnet IDs in the specified availability zone"
  type        = list(string)
}

variable "secret_naming_convention" {
  description = "Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager."
  type        = string
  default     = ""
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to automatically grant admin permissions to the cluster creator's IAM role. "
  type        = bool
  default     = true
}