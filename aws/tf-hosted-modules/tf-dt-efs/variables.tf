variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  type        = string
}

variable "eks_cluster_certificate" {
  description = "The base64 encoded certificate for the EKS cluster."
  type        = string
}

variable "eks_cluster_token" {
  description = "The authentication token for the EKS cluster."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  default     = {}
  type        = map(string)
}

variable "availability_zone_name" {
  description = "For One Zone file systems, specify the AWS Availability Zone in which to create the file system."
  type        = string
  default     = "us-east-1a"
}

variable "cluster_name_prefix" {
  description = "Cluster name and prefix for all the associated resources"
  type        = string
}

variable "private_subnet" {
  description = "Id of private subnet CIDR block, in the AZ zone specified"
  type        = string
}

variable "node_security_group_id" {
  description = "ID of the node shared security group"
  type        = string
}

variable "appuser_id" {
  description = "The user ID for the application user."
  type        = string
  default     = "65532"
}
