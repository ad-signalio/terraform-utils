locals {
  subnet_name         = "${var.env_name}-private"
  pods_range_name     = "${var.env_name}-pods"
  services_range_name = "${var.env_name}-services"
}

# This module enables the APIs it needs (compute for the VPC, servicenetworking
# for Private Service Access). disable_on_destroy = false is deliberate: these
# APIs are shared with other modules (GKE, Filestore, Cloud SQL), so tearing
# down this module must never disable an API the others still depend on.
# Enabling is idempotent, so it's fine for several modules to enable the same API.
resource "google_project_service" "required" {
  for_each = toset([
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Wrap the official terraform-google-modules network module (mirrors how the AWS
# tf-dt-vpc wraps terraform-aws-modules/vpc/aws). Custom-mode VPC + one regional
# node subnet with VPC-native secondary ranges for GKE pods and services.
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 18.0"

  depends_on = [google_project_service.required]

  project_id   = var.project_id
  network_name = var.env_name
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = local.subnet_name
      subnet_ip             = var.subnet_cidr
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
    (local.subnet_name) = [
      { range_name = local.pods_range_name, ip_cidr_range = var.pods_cidr },
      { range_name = local.services_range_name, ip_cidr_range = var.services_cidr },
    ]
  }
}

# Cloud Router + Cloud NAT give private nodes outbound internet
# (the GCP equivalent of the AWS NAT Gateway).
module "cloud_nat" {
  source  = "terraform-google-modules/cloud-nat/google"
  version = "~> 7.0"

  depends_on = [google_project_service.required]

  project_id    = var.project_id
  region        = var.region
  network       = module.vpc.network_name
  create_router = true
  router        = "${var.env_name}-router"
  name          = "${var.env_name}-nat"
}

# --- Firewall rules (custom-mode VPC has only implied allow-egress /
# deny-ingress, so ingress must be opened explicitly) ---

# Intra-VPC traffic between nodes, pods and services.
resource "google_compute_firewall" "allow_internal" {
  name      = "${var.env_name}-allow-internal"
  project   = var.project_id
  network   = module.vpc.network_name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr, var.pods_cidr, var.services_cidr]
}

# Google front-end / health-check ranges (load balancers, GKE health checks).
resource "google_compute_firewall" "allow_health_checks" {
  name      = "${var.env_name}-allow-health-checks"
  project   = var.project_id
  network   = module.vpc.network_name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

# Optional: SSH via IAP TCP forwarding (no public IPs needed).
resource "google_compute_firewall" "allow_iap_ssh" {
  count     = var.enable_iap_ssh ? 1 : 0
  name      = "${var.env_name}-allow-iap-ssh"
  project   = var.project_id
  network   = module.vpc.network_name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

# Optional: let the private GKE control plane reach nodes for admission
# webhooks / metrics. master_ipv4_cidr comes from the GKE module.
resource "google_compute_firewall" "allow_control_plane" {
  count     = var.control_plane_cidr == "" ? 0 : 1
  name      = "${var.env_name}-allow-control-plane"
  project   = var.project_id
  network   = module.vpc.network_name
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443", "8443", "9443", "10250"]
  }

  source_ranges = [var.control_plane_cidr]
}

# --- Private Service Access: reserve a range and peer it to Google-managed
# services so Cloud SQL / Memorystore can get private IPs.
# Kept as raw resources (the network module's PSA submodule exposes no outputs)
# so we can surface the range name + connection id below. ---
# The global address uses network_self_link (always the project-ID self-link)
# rather than network_id: network_id's string form follows how the project is
# supplied (ID vs number), and when given as a number it becomes
# "projects/<number>/..." which (a) forces a spurious replacement of this
# reserved range (network is ForceNew here) and (b) is rejected by consumers
# like Cloud SQL ("project id must start with a lowercase letter").
resource "google_compute_global_address" "psa" {
  name          = "${var.env_name}-psa"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.psa_prefix_length
  network       = module.vpc.network_self_link
}

# The peering connection stays on network_id: its network is also ForceNew, so
# switching the form on an already-created connection replaces the live peering
# (and disrupts any managed service using it). network_id is form-stable for an
# existing connection, so don't change it.
resource "google_service_networking_connection" "psa" {
  network                 = module.vpc.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa.name]
}
