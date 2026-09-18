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

variable "install_crds_separately" {
  description = "Whether to install KEDA CRDs separately from the Helm chart (not recommended for production)"
  type        = bool
  default     = false
}

variable "enabled" {
  description = "Whether to enable the KEDA module. Set to false to only install CRDs using the manifest resource."
  type        = bool
  default     = true
}

variable "application_namespace" {
  description = "Name of the namespace where Keda will watch to scale workloads."
  type        = string
  default     = "match"
}

variable "create_match_namespace" {
  description = "Whether to create the application namespace (e.g. 'match') as part of this module. Off by default: a scaling module is a poor owner for the application namespace, and something else generally needs it earlier -- tf-dt-eks-secret-provider-classes creates it by default. Set true when nothing else does."
  type        = bool
  default     = false
}