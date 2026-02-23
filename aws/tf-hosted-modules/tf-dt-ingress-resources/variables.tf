variable "eks_cluster_name" {
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

