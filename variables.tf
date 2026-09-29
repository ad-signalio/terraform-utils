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

variable "docker_secret_name" {
  description = "Secrets Manager name of the hand-created Docker registry credentials. Must be one of tf-dt-eks's hand_created_secret_names, or the IRSA role cannot read it."
  type        = string
  default     = "match-docker-secret"
}

variable "honeybadger_secret_name" {
  description = "Secrets Manager name of the hand-created Honeybadger API key. Must be one of tf-dt-eks's hand_created_secret_names, or the IRSA role cannot read it."
  type        = string
  default     = "match-honeybadger-secret"
}

variable "k8s_rds_pg_secret_name" {
  description = "Kubernetes Secret the Postgres credentials sync into. The match chart's postgres.*Secret values must match this."
  type        = string
  default     = "match-postgres-credentials"
}

variable "namespace" {
  description = "Namespace the release and every object in it are created in. The platform chart uses \"snicketlabs\"."
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
  description = "Chart version. 0.2.0 is the first that honours var.namespace and the Secret name inputs."
  type        = string
  default     = "0.2.0"
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

variable "k8s_api_secret_name" {
  description = "Kubernetes Secret the Rails secrets sync into. The platform chart uses \"api-secrets\"."
  type        = string
  default     = "match-api-secrets"
}

variable "k8s_owning_user_secret_name" {
  description = "Kubernetes Secret the owning user password syncs into. The platform chart uses \"owning-user-credentials\"."
  type        = string
  default     = "match-owning-user-credentials"
}
