# APIs this module needs (self-contained, disable_on_destroy=false — same
# convention as the other gcp modules). servicenetworking (for PSA) is enabled
# by tf-dt-vpc.
resource "google_project_service" "required" {
  for_each = toset([
    "redis.googleapis.com",
    "secretmanager.googleapis.com",
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Wrap the official Memorystore module (mirrors how the AWS tf-dt-elasticache-redis
# wraps terraform-aws-modules/elasticache/aws). Redis over Private Service Access —
# private IP in the VPC, same connection pattern as ElastiCache, no app changes.
module "redis" {
  source  = "terraform-google-modules/memorystore/google"
  version = "~> 16.0"

  depends_on = [google_project_service.required]

  project_id     = var.project_id
  name           = "${var.env_name}-redis"
  region         = var.region
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  redis_version  = var.redis_version

  # Private connectivity via the VPC's Private Service Access peering.
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  authorized_network      = var.network
  reserved_ip_range       = var.reserved_ip_range
  auth_enabled            = var.auth_enabled
  transit_encryption_mode = var.transit_encryption_mode
}

resource "google_secret_manager_secret" "connection" {
  count     = var.create_secret ? 1 : 0
  project   = var.project_id
  secret_id = "${var.env_name}-redis"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

locals {
  # rediss:// when in-transit encryption is on, redis:// otherwise — so the
  # connection URL matches the instance's TLS setting (a redis:// URL against a
  # TLS-only instance fails to connect).
  redis_scheme   = var.transit_encryption_mode == "DISABLED" ? "redis" : "rediss"
  redis_userinfo = var.auth_enabled ? ":${module.redis.auth_string}@" : ""
  redis_url      = "${local.redis_scheme}://${local.redis_userinfo}${module.redis.host}:${module.redis.port}"
}

resource "google_secret_manager_secret_version" "connection" {
  count  = var.create_secret ? 1 : 0
  secret = google_secret_manager_secret.connection[0].id
  secret_data = jsonencode({
    host = module.redis.host
    port = module.redis.port
    auth = module.redis.auth_string
    url  = local.redis_url
  })
}
