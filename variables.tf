variable "project_id" {
  description = "GCP project ID the GSA is created in."
  type        = string
}

variable "name" {
  description = "Base name for the GCP service account (and the default KSA name)."
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name (used to resolve the cluster for the KSA annotation)."
  type        = string
}

variable "location" {
  description = "GKE cluster location (region or zone)."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account."
  type        = string
  default     = "match"
}

variable "k8s_sa_name" {
  description = "Kubernetes ServiceAccount name. Keep this identical across clouds for chart portability. Defaults to var.name."
  type        = string
  default     = null
}

variable "use_existing_k8s_sa" {
  description = "If true, annotate an existing KSA (e.g. one created by the helm-match chart) rather than create it. The chart-portable pattern: chart owns the KSA, this only adds the iam.gke.io annotation."
  type        = bool
  default     = false
}

variable "annotate_k8s_sa" {
  description = "Add the iam.gke.io/gcp-service-account annotation binding the KSA to the GSA."
  type        = bool
  default     = true
}

variable "roles" {
  description = "Project IAM roles to grant the GSA (e.g. roles/secretmanager.secretAccessor). Bucket-scoped grants (GCS) are done on the bucket via tf-dt-gcs-active-storage instead."
  type        = list(string)
  default     = []
}
