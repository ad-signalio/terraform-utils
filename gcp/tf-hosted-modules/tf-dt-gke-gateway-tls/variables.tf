variable "project_id" {
  type        = string
  description = "GCP project ID. Used for the reserved global external address."
}

variable "namespace" {
  type        = string
  default     = "match"
  description = "Namespace for the Gateway + Certificate (and the helm release). Created if create_namespace = true. HTTPRoutes attach from here (allowed_routes_from = Same)."
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Have the helm release create var.namespace if it doesn't exist."
}

variable "release_name" {
  type        = string
  default     = "match-gateway-tls"
  description = "Name of the helm release that ships the Gateway/Issuer/Certificate CRs."
}

variable "gateway_name" {
  type        = string
  default     = "match-gateway"
  description = "Name of the Gateway resource. Use as the HTTPRoute parentRefs[].name."
}

variable "gateway_class_name" {
  type        = string
  default     = "gke-l7-global-external-managed"
  description = "GatewayClass. gke-l7-global-external-managed = global external L7 LB (needs the cluster's Gateway API channel enabled)."
}

variable "allowed_routes_from" {
  type        = string
  default     = "Same"
  description = "allowedRoutes.namespaces.from for the listeners (Same | All | Selector)."
}

variable "enable_tls" {
  type        = bool
  default     = true
  description = "Add the HTTPS:443 listener + reserved static IP, and create the ClusterIssuer + Certificate + Cloudflare token Secret. false = HTTP-only Gateway, no cert-manager objects. Requires hostname, acme_email, cloudflare_api_token when true."
}

variable "hostname" {
  type        = string
  default     = ""
  description = "Hostname for the HTTPS listener and the certificate's dnsNames. Required when enable_tls."
}

variable "tls_secret_name" {
  type        = string
  default     = "match-tls"
  description = "Secret cert-manager writes the cert/key into; consumed by the Gateway HTTPS listener."
}

variable "cluster_issuer_name" {
  type        = string
  default     = "letsencrypt-prod"
  description = "Name of the cert-manager ClusterIssuer created (and referenced by the Certificate)."
}

variable "acme_server" {
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
  description = "ACME directory URL. Default = Let's Encrypt production. Staging = https://acme-staging-v02.api.letsencrypt.org/directory."
}

variable "acme_email" {
  type        = string
  default     = ""
  description = "Email for the ACME account. Required when enable_tls."
}

variable "cloudflare_api_token" {
  type        = string
  default     = null
  sensitive   = true
  description = "Cloudflare API token (Zone:DNS:Edit + Zone:Read) for the DNS-01 solver. Required when enable_tls. Passed through the helm release values (lands in TF state)."
}

variable "cert_manager_namespace" {
  type        = string
  default     = "cert-manager"
  description = "Namespace cert-manager runs in — the Cloudflare token Secret is created here so the solver can read it."
}

variable "create_static_ip" {
  type        = bool
  default     = null
  description = "Reserve a global external IP and bind it to the Gateway. Defaults to enable_tls (TLS needs a stable DNS target)."
}

variable "static_ip_name" {
  type        = string
  default     = null
  description = "Name for the reserved global address. Defaults to \"<gateway_name>-ip\"."
}
