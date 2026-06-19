variable "enabled" {
  description = "Whether to install the External Secrets Operator."
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Version of the external-secrets Helm chart."
  type        = string
  default     = "2.6.0"
}

variable "namespace" {
  description = "Namespace to install ESO into (created if absent)."
  type        = string
  default     = "external-secrets"
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
