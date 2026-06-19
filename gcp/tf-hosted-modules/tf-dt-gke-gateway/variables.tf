variable "project_id" {
  type        = string
  description = "GCP project ID. Used for the reserved global external address."
}

variable "gateway_name" {
  type        = string
  default     = "match-gateway"
  description = "Name of the Gateway resource. Use this as the HTTPRoute parentRefs[].name."
}

variable "namespace" {
  type        = string
  description = "Namespace the Gateway is created in. HTTPRoutes attach from the same namespace (allowed_routes_from = Same), so no ReferenceGrant is needed."
}

variable "gateway_class_name" {
  type        = string
  default     = "gke-l7-global-external-managed"
  description = "GatewayClass. gke-l7-global-external-managed = global external L7 load balancer (built into GKE once the Gateway API channel is enabled on the cluster)."
}

variable "enable_tls" {
  type        = bool
  default     = false
  description = "Add an HTTPS:443 listener (terminating TLS from tls_secret_name) and bind a reserved static IP. The HTTP:80 listener is always present. Requires hostname when true."
}

variable "hostname" {
  type        = string
  default     = ""
  description = "Hostname for the HTTPS listener (must match the TLS cert's dnsNames). Required when enable_tls = true."
}

variable "tls_secret_name" {
  type        = string
  default     = "match-tls"
  description = "Name of the Secret (in namespace) holding the TLS cert/key the HTTPS listener terminates with. Populated externally — e.g. a cert-manager Certificate shipped by the app chart, or a manually-created Secret. This module does NOT create the cert."
}

variable "create_static_ip" {
  type        = bool
  default     = null
  description = "Reserve a global external IP and bind it to the Gateway via spec.addresses (NamedAddress). Defaults to enable_tls (TLS needs a stable DNS target). Set explicitly to reserve an IP for the HTTP-only case too."
}

variable "static_ip_name" {
  type        = string
  default     = null
  description = "Name for the reserved global address. Defaults to \"<gateway_name>-ip\"."
}

variable "annotations" {
  type        = map(string)
  default     = {}
  description = "Extra annotations on the Gateway. e.g. set cert-manager.io/cluster-issuer here to use cert-manager's gateway-shim auto-issuance instead of an explicit Certificate (note: gateway-shim needs the ExperimentalGatewayAPISupport feature gate enabled on cert-manager)."
}

variable "allowed_routes_from" {
  type        = string
  default     = "Same"
  description = "allowedRoutes.namespaces.from for the listeners. Same = only HTTPRoutes in the Gateway's namespace may attach. Other values: All, Selector."
}
