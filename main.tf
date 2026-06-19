# GSA creation needs the IAM API (self-contained, disable_on_destroy=false —
# same convention as the other gcp modules). Usually already enabled by the
# gcp-foundation bootstrap; enabling again is idempotent.
resource "google_project_service" "required" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Wrap the official Workload Identity submodule: creates (or reuses) the GSA,
# binds roles/iam.workloadIdentityUser between the KSA and GSA, grants project
# roles to the GSA, and annotates the KSA. This is the GCP analogue of AWS IRSA
# trust lives on the GSA instead of the IAM role.
module "workload_identity" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version = "~> 44.0"

  depends_on = [google_project_service.required]

  project_id   = var.project_id
  name         = var.name
  cluster_name = var.cluster_name
  location     = var.location

  namespace           = var.namespace
  k8s_sa_name         = var.k8s_sa_name
  use_existing_k8s_sa = var.use_existing_k8s_sa
  annotate_k8s_sa     = var.annotate_k8s_sa

  roles = var.roles
}
