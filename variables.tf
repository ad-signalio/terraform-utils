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

variable "private_subnets" {
  description = "A list of all private subnets, containing the full objects."
  type = list(object({
    arn                                            = string
    assign_ipv6_address_on_creation                = bool
    availability_zone                              = string
    availability_zone_id                           = string
    cidr_block                                     = string
    customer_owned_ipv4_pool                       = string
    enable_dns64                                   = bool
    enable_lni_at_device_index                     = number
    enable_resource_name_dns_a_record_on_launch    = bool
    enable_resource_name_dns_aaaa_record_on_launch = bool
    id                                             = string
    ipv4_ipam_pool_id                              = string
    ipv4_netmask_length                            = number
    ipv6_cidr_block                                = string
    ipv6_cidr_block_association_id                 = string
    ipv6_ipam_pool_id                              = string
    ipv6_native                                    = bool
    ipv6_netmask_length                            = number
    map_customer_owned_ip_on_launch                = bool
    map_public_ip_on_launch                        = bool
    outpost_arn                                    = string
    owner_id                                       = string
    private_dns_hostname_type_on_launch            = string
    region                                         = string
    tags                                           = map(string)
    tags_all                                       = map(string)
    vpc_id                                         = string
  }))
}

variable "availability_zone_name" {
  description = "For One Zone systems, specify the AWS Availability Zone in which to create the EKS cluster and EFS."
  type        = string
}

variable "cluster_name_prefix" {
  description = "Cluster name and prefix for all the associated resources"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security group IDs to associate"
  type        = list(string)
  validation {
    condition     = length(var.vpc_security_group_ids) <= 5
    error_message = "You can specify up to 5 security group IDs."
  }
}

variable "appuser_id" {
  description = "The user ID for the application user."
  type        = string
  default     = "65532"
}
