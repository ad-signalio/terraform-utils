# Enable the APIs this module needs (self-contained, like tf-dt-vpc).
# disable_on_destroy = false so a teardown never disables an API a sibling
# module still relies on (enable is idempotent).
resource "google_project_service" "required" {
  for_each = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
  ])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Wrap the official terraform-google-modules private-cluster module (mirrors how
# the AWS tf-dt-eks wraps terraform-aws-modules/eks/aws). GKE Standard, private
# nodes, Workload Identity, dedicated node service account.
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 44.0"

  depends_on = [google_project_service.required]

  project_id = var.project_id
  name       = var.cluster_name
  region     = var.region
  regional   = var.regional
  zones      = var.zones

  network           = var.network
  subnetwork        = var.subnetwork
  ip_range_pods     = var.pods_range_name
  ip_range_services = var.services_range_name

  # Private cluster: nodes never get public IPs. enable_private_endpoint toggles
  # whether the control-plane endpoint is private-only too.
  enable_private_nodes       = true
  enable_private_endpoint    = var.enable_private_endpoint
  master_ipv4_cidr_block     = var.master_ipv4_cidr_block
  master_authorized_networks = var.master_authorized_networks

  # Workload Identity. identity_namespace="enabled" sets the pool to
  # <project>.svc.id.goog; node_metadata=GKE_METADATA must be on every node pool
  # or WI silently falls back to the node SA.
  identity_namespace = "enabled"
  node_metadata      = "GKE_METADATA"

  # Dedicated least-privilege node SA (not the default compute SA).
  create_service_account = true
  grant_registry_access  = true

  remove_default_node_pool = true
  release_channel          = var.release_channel
  deletion_protection      = var.deletion_protection

  # Gateway API. CHANNEL_STANDARD installs the Gateway API CRDs and the
  # GKE managed GatewayClasses (gke-l7-global-external-managed, etc.). null leaves
  # it disabled. The upstream module only renders gateway_api_config when non-null.
  gateway_api_channel = var.gateway_api_channel

  node_pools = [
    {
      name         = "default"
      machine_type = var.machine_type
      min_count    = var.min_node_count
      max_count    = var.max_node_count
      auto_repair  = true
      auto_upgrade = true
    }
  ]

  # cloud-platform scope is required for the Workload Identity token exchange.
  node_pools_oauth_scopes = {
    all = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
