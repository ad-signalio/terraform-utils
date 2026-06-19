variable "enabled" {
  type        = bool
  default     = true
  description = "Install external-dns. false = create nothing."
}

variable "chart_version" {
  type        = string
  default     = "1.15.2"
  description = "Version of the external-dns Helm chart (kubernetes-sigs.github.io/external-dns)."
}

variable "namespace" {
  type        = string
  default     = "external-dns"
  description = "Namespace to install external-dns into."
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Create var.namespace (dedicated to external-dns). Set false to manage it elsewhere."
}

variable "dns_provider" {
  type        = string
  default     = "cloudflare"
  description = "external-dns provider (--provider). cloudflare is the only one wired for token auth here; others need their own creds."
}

variable "sources" {
  type        = list(string)
  default     = ["gateway-httproute"]
  description = "external-dns sources (--source). gateway-httproute reads HTTPRoutes + their parent Gateway's address. Add service/ingress/gateway-grpcroute etc. as needed."
}

variable "domain_filters" {
  type        = list(string)
  default     = []
  description = "Zones external-dns is allowed to manage (--domain-filter), e.g. [\"example.com\"]. Strongly recommended to scope it."
}

variable "policy" {
  type        = string
  default     = "upsert-only"
  description = "Record lifecycle (--policy): upsert-only (never delete) or sync (delete records when the source is removed — enables auto-cleanup on teardown). Only affects records external-dns owns (tracked via the TXT registry)."
}

variable "txt_owner_id" {
  type        = string
  default     = "external-dns"
  description = "Owner ID for the TXT-registry ownership records (--txt-owner-id). Make it unique per cluster so multiple external-dns instances don't fight over the same zone."
}

variable "cloudflare_api_token" {
  type        = string
  default     = null
  sensitive   = true
  description = "Cloudflare API token (Zone:DNS:Edit + Zone:Read). Required when create_token_secret = true. Passed into the token Secret (lands in TF state)."
}

variable "create_token_secret" {
  type        = bool
  default     = true
  description = "Create the Cloudflare API token Secret from cloudflare_api_token. Set false to reference a pre-existing (e.g. ESO-synced) secret — keeps the token out of TF state."
}

variable "token_secret_name" {
  type        = string
  default     = "cloudflare-api-token"
  description = "Name of the Secret holding the Cloudflare API token (mounted as CF_API_TOKEN)."
}

variable "token_secret_key" {
  type        = string
  default     = "api-token"
  description = "Key within token_secret_name holding the token."
}

variable "settings" {
  type        = any
  default     = {}
  description = "Extra Helm values for the external-dns chart, merged over the module defaults (deep-merged by Helm)."
}

variable "values" {
  type        = list(string)
  default     = []
  description = "Raw Helm values documents (YAML strings) appended last."
}
