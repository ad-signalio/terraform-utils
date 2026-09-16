variable "enabled" {
  description = "Create the SecretProviderClasses. Off by default: it changes where the application's secrets come from -- see match_helm_values."
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "EKS cluster name. Used to derive the Redis secret name the chart creates."
  type        = string
}

variable "secret_store_role_arn" {
  description = "IRSA role the CSI driver assumes to read Secrets Manager. tf-dt-eks output secrets_csi_irsa_role_arn."
  type        = string
}

variable "api_secret_name" {
  description = "Secrets Manager name holding the Rails secrets. tf-dt-application-secrets output api_secret_name."
  type        = string
}

variable "user_secret_name" {
  description = "Secrets Manager name holding the owning user password. tf-dt-application-secrets output user_secret_name."
  type        = string
}

variable "rds_pg_secret_name" {
  description = "Secrets Manager name holding the Postgres credentials. tf-dt-rds-pg output rds_pg_secret_name."
  type        = string
}

variable "redis_secret_name" {
  description = "Secrets Manager name holding the Redis URL. tf-dt-elasticache-redis output redis_secret_name."
  type        = string
}

variable "smtp_secret_name" {
  description = "Secrets Manager name holding SMTP credentials. Empty disables the SMTP SecretProviderClass."
  type        = string
  default     = ""
}

variable "k8s_rds_pg_secret_name" {
  description = "Kubernetes Secret the Postgres credentials sync into. The match chart's postgres.*Secret values must match this."
  type        = string
  default     = "match-postgres-credentials"
}

variable "namespace" {
  description = "Namespace holding the release record. The chart hardcodes \"match\" in its own templates, so this does not move the objects."
  type        = string
  default     = "match"
}

variable "create_namespace" {
  description = "Create the namespace if absent. On by default: these secrets have to exist before anything that consumes them, so this module is usually first into the namespace."
  type        = bool
  default     = true
}

variable "secret_syncer_image" {
  description = "Image for the syncer pod. It only sleeps, so anything with a shell will do."
  type        = string
  default     = "public.ecr.aws/docker/library/busybox:1.36"
}

variable "chart_repository" {
  description = "Helm repository serving the chart. Public, so no credentials are needed."
  type        = string
  default     = "https://ad-signalio.github.io/helm-charts"
}

variable "chart_name" {
  description = "Chart to install. The AWS variant; secrets-configuration-gcp is the ESO equivalent."
  type        = string
  default     = "secrets-configuration-aws"
}

variable "chart_version" {
  description = "Chart version."
  type        = string
  default     = "0.1.0"
}

variable "release_name" {
  description = "Helm release name."
  type        = string
  default     = "match-secrets"
}

variable "wait" {
  description = "Wait for readiness. The syncer is a Deployment, so this needs schedulable compute."
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Seconds to wait for the release."
  type        = number
  default     = 600
}
