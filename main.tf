# Enable the Storage API (self-contained, disable_on_destroy=false — same
# convention as the other gcp modules).
resource "google_project_service" "required" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

# Active Storage bucket — the GCP equivalent of the AWS tf-dt-s3-active-storage
# bucket. Private, versioned, uniform access, encrypted at rest.
resource "google_storage_bucket" "primary" {
  project                     = var.project_id
  name                        = "${var.env_name}-primary"
  location                    = var.location
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = var.versioning
  }

  # CORS for Active Storage direct uploads — mirrors the S3 CORS policy
  # (methods PUT/GET, the same exposed/response headers, 1h max-age).
  dynamic "cors" {
    for_each = length(var.app_url) > 0 ? [1] : []
    content {
      origin          = var.app_url
      method          = ["PUT", "GET"]
      response_header = ["Origin", "Content-Type", "Content-MD5", "Content-Disposition"]
      max_age_seconds = 3600
    }
  }

  # Google-managed encryption by default; customer-managed KMS key if provided.
  dynamic "encryption" {
    for_each = var.kms_key_name == null ? [] : [1]
    content {
      default_kms_key_name = var.kms_key_name
    }
  }

  depends_on = [google_project_service.required]
}

# Grant the application's Workload Identity GSA object access.
# Optional: skipped until the GSA exists.
resource "google_storage_bucket_iam_member" "app_object_user" {
  count  = var.service_account_email == "" ? 0 : 1
  bucket = google_storage_bucket.primary.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${var.service_account_email}"
}

# --- S3-interoperability access  ---
# The match app's Active Storage uses the S3 API (Service::S3StreamingService),
# so on GCP it talks to the GCS XML/S3 API at https://storage.googleapis.com
# with HMAC keys (static creds) rather than native GCS. The HMAC key is tied to
# the app GSA, so its object permissions come from that GSA's objectUser grant
# above — create_hmac_key therefore requires service_account_email.
resource "google_storage_hmac_key" "app" {
  count                 = var.create_hmac_key ? 1 : 0
  project               = var.project_id
  service_account_email = var.service_account_email

  lifecycle {
    precondition {
      condition     = var.service_account_email != ""
      error_message = "create_hmac_key requires service_account_email (the app GSA the HMAC key is tied to)."
    }
  }
}

# secretmanager API for the HMAC secret (only when needed; storage.googleapis.com
# is enabled above). Separate resource so the existing singular enablement keeps
# its state address. disable_on_destroy=false per the gcp-module convention.
resource "google_project_service" "secretmanager" {
  count              = var.create_hmac_key ? 1 : 0
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Stash the HMAC access_id + secret in Secret Manager so ESO can sync them into
# the cluster (mirrors how tf-dt-memorystore/tf-dt-cloud-sql store connection
# secrets). JSON {access_id, secret}; the secret is only retrievable at create.
resource "google_secret_manager_secret" "hmac" {
  count     = var.create_hmac_key ? 1 : 0
  project   = var.project_id
  secret_id = "${var.env_name}-gcs-hmac"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "hmac" {
  count  = var.create_hmac_key ? 1 : 0
  secret = google_secret_manager_secret.hmac[0].id
  secret_data = jsonencode({
    access_id = google_storage_hmac_key.app[0].access_id
    secret    = google_storage_hmac_key.app[0].secret
  })
}
