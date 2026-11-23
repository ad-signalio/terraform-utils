variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to grant access to"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_issuer_url" {
  description = "OIDC issuer URL of the EKS cluster"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "default"
}

variable "kubernetes_service_account" {
  description = "Name of the Kubernetes service account"
  type        = string
}

variable "grafana_kubernetes_service_account" {
  description = "Service account Grafana runs under. Its own, not the application's: the application role carries the s3-ingest-assume-role policy, whose in-account Deny on sts:AssumeRole beats any allow and stops Grafana reaching the CloudWatch role."
  type        = string
  default     = "grafana"
}

variable "domain_name" {
  description = "Names of domain name to associate with the load balancer if on route53"
  type        = string
}

variable "adsignal_org" {
  description = "The Ad Signal organization name, typically 'adsignal'"
  type        = string
  default     = "adsignal"
}

variable "ingest_buckets" {
  description = "Buckets this environment ingests customer content FROM. Not created or owned by this stack, unlike s3_bucket_name, so they are granted through their own policy that can be narrowed or detached independently. Names, not ARNs."
  type        = list(string)
  default     = []
}

variable "allow_s3_ingest_role_assumption" {
  description = "Whether the platform may assume S3 ingest roles in other AWS accounts. Required for ingest sources that use cross-account IAM role assumption with an external ID; the application feature is unusable without it. Never permits assuming a role in this account."
  type        = bool
  default     = true
}

variable "allow_autoingest" {
  description = "Whether the platform may provision AutoIngest resources: S3 buckets, SNS topics and IAM users with access keys, all named *-autoingest*. Not typically enabled on client-hosted systems: leave it off unless the client has asked for AutoIngest. It lets the application create IAM users and attach inline policies to them in the client's account. POC environments generally enable it."
  type        = bool
  default     = false
}
