# APIs this module needs (self-contained, disable_on_destroy=false — same
# convention as the other gcp modules). servicenetworking (for the private IP)
# is enabled by tf-dt-vpc.
resource "google_project_service" "required" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "random_password" "db" {
  length  = 24
  special = false
}

# Wrap the official Cloud SQL module (mirrors how the AWS tf-dt-rds-pg wraps
# terraform-aws-modules/rds/aws). PostgreSQL, private IP only via Private
# Service Access — pods connect directly, no Cloud SQL Auth Proxy sidecar.
module "postgresql" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 28.0"

  depends_on = [google_project_service.required]

  project_id           = var.project_id
  name                 = "${var.env_name}-pg"
  random_instance_name = var.random_instance_name
  database_version     = var.database_version
  region               = var.region
  zone                 = var.zone
  edition              = var.edition
  tier                 = var.tier
  availability_type    = var.availability_type

  disk_size       = var.disk_size
  disk_autoresize = var.disk_autoresize
  database_flags  = var.database_flags

  # Application database + user (password generated above).
  db_name             = var.db_name
  enable_default_user = true
  user_name           = var.db_user
  user_password       = random_password.db.result

  # Private IP only, encrypted connections only, drawn from the reserved PSA range.
  ip_configuration = {
    ipv4_enabled       = false
    private_network    = var.private_network
    ssl_mode           = "ENCRYPTED_ONLY"
    allocated_ip_range = var.allocated_ip_range
  }

  deletion_protection         = var.deletion_protection
  deletion_protection_enabled = var.deletion_protection
}

resource "google_secret_manager_secret" "connection" {
  count     = var.create_secret ? 1 : 0
  project   = var.project_id
  secret_id = "${var.env_name}-cloud-sql"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "connection" {
  count  = var.create_secret ? 1 : 0
  secret = google_secret_manager_secret.connection[0].id
  secret_data = jsonencode({
    host            = module.postgresql.private_ip_address
    port            = 5432
    dbname          = var.db_name
    username        = var.db_user
    password        = random_password.db.result
    connection_name = module.postgresql.instance_connection_name
  })
}
