variable "chart_version" {
  description = "Version of the KEDA Helm chart"
  type        = string
  default     = "2.19.0"
}

variable "namespace" {
  description = "Namespace to install KEDA"
  type        = string
  default     = "keda"
}

variable "settings" {
  description = "Additional settings to pass to the Helm chart"
  type        = map(any)
  default     = {}
}

variable "values" {
  description = "List of values in raw YAML format to pass to the helm release"
  type        = list(string)
  default     = []
}

variable "install_crds" {
  description = "Whether to install KEDA CRDs using the Helm chart (not recommended for production)"
  type        = bool
  default     = true
}

variable "enabled" {
  description = "Whether to enable the KEDA module"
  type        = bool
  default     = false
}

variable "eks_cluster_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}