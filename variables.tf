variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "app_url" {
  description = "The URL of the application"
  type        = list(string)
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket"
  default     = {}
  type        = map(string)
}
