variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "availability_zone_count" {
  description = "The number of availability zones to use"
  type        = number
  default     = 2
  validation {
    condition     = var.availability_zone_count >= 1 && var.availability_zone_count <= 6
    error_message = "availability_zone_count must be between 1 and 6."
  }
}
