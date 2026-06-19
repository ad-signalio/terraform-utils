variable "enabled" {
  description = "Whether to install cert-manager."
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Version of the cert-manager Helm chart (jetstack). >= v1.15 supports crds.enabled and the Gateway API feature gate."
  type        = string
  default     = "v1.16.2"
}

variable "namespace" {
  description = "Namespace to install cert-manager into (created if absent)."
  type        = string
  default     = "cert-manager"
}

variable "settings" {
  description = "Additional settings merged into the Helm values (override module defaults)."
  type        = map(any)
  default     = {}
}

variable "values" {
  description = "List of raw YAML value documents passed to the Helm release."
  type        = list(string)
  default     = []
}
