# Enable the Secret Manager API (self-contained, disable_on_destroy=false).
resource "google_project_service" "required" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "random_password" "secret_key_base" {
  length  = 64
  special = false
}

resource "random_id" "api_secret_key_base" {
  byte_length = 64
}

resource "random_id" "ingest_credential_encryption_key" {
  byte_length = 32
}

resource "random_password" "user_password" {
  # The match app requires the owning user's password to contain an uppercase
  # letter, a lowercase letter, a number AND a symbol (User PASSWORD_REQUIREMENTS).
  # An all-alphanumeric password (special=false) fails that validation, and the
  # owning user is silently never seeded (find_or_create_by swallows it). Force a
  # compliant mix; override_special stays within the app's accepted symbol set.
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!@#$%^&*-_=+"
}

# --- api-secrets: Rails app secrets (one JSON secret) ---
resource "google_secret_manager_secret" "api_secrets" {
  project   = var.project_id
  secret_id = "${var.env_name}-api-secrets"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "api_secrets" {
  secret = google_secret_manager_secret.api_secrets.id
  secret_data = jsonencode({
    secret_key_base                  = random_password.secret_key_base.result
    api_secret_key_base              = random_id.api_secret_key_base.hex
    ingest_credential_encryption_key = random_id.ingest_credential_encryption_key.hex
  })
}

# --- user-password: owning user's initial password ---
resource "google_secret_manager_secret" "user_password" {
  project   = var.project_id
  secret_id = "${var.env_name}-user-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "user_password" {
  secret = google_secret_manager_secret.user_password.id
  secret_data = jsonencode(merge(
    { password = random_password.user_password.result },
    var.owning_user_email == "" ? {} : { username = var.owning_user_email },
  ))
}
