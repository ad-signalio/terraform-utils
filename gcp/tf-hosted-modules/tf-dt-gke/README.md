# tf-dt-gke (GCP)

GKE cluster for the GCP reference architecture - the GCP equivalent of the AWS
`tf-dt-eks` module. Like that module wraps `terraform-aws-modules/eks/aws`, this
wraps the official `terraform-google-modules/kubernetes-engine/google//modules/private-cluster`,
configured for Workload Identity and private nodes.

## What it creates

- **`terraform-google-modules/.../private-cluster`** (`~> 44.0`) - a GKE Standard,
  VPC-native cluster with private nodes, one autoscaling node pool, and a
  dedicated least-privilege node service account.
- **`google_project_service`** - enables `container` + `compute`
  (`disable_on_destroy = false`, same convention as tf-dt-vpc).

## Critical settings

- **Workload Identity**: `identity_namespace = "enabled"` → pool `<project>.svc.id.goog`.
- **`node_metadata = "GKE_METADATA"`** on the node pool - without it WI silently
  falls back to the node SA.
- **`cloud-platform` oauth scope** on the pool - required for the WI token exchange.
- **Dedicated node SA** (`create_service_account = true`) - not the default compute SA.

## Endpoint exposure

`enable_private_nodes = true` always (nodes have no public IPs). The control-plane
endpoint is controlled by `enable_private_endpoint`:

- **`false` (default)** - public endpoint; lock it down with `master_authorized_networks`.
  Keeps the Terraform kubernetes/helm providers (and CI) able to reach the cluster.
- **`true`** - private-only endpoint; **requires** VPN / bastion / IAP for any
  kubectl or Terraform k8s-provider access. Use once private connectivity exists.

## Wiring (consumes tf-dt-vpc outputs)

```hcl
module "gke" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-gke?ref=<tag-or-branch>"

  project_id          = var.gcp_project_id
  cluster_name        = "sbox-adsignal-shared-us1"
  region              = var.region
  regional            = false
  zones               = [var.zone] # zonal sandbox; omit + regional=true for HA

  network             = module.vpc.network_name
  subnetwork          = module.vpc.subnet_name
  pods_range_name     = module.vpc.pods_range_name
  services_range_name = module.vpc.services_range_name

  master_ipv4_cidr_block = "172.16.0.0/28" # also → vpc control_plane_cidr
}
```

Pass `master_ipv4_cidr_block` to the VPC module's `control_plane_cidr` so the
`allow-control-plane` firewall rule lets the control plane reach nodes (webhooks).

Outputs `cluster_endpoint` / `cluster_ca_certificate` / `cluster_name` feed the
Terraform kubernetes & helm providers in the environment.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.17.0, < 8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google//modules/private-cluster | ~> 44.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the GKE cluster. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Block Terraform from destroying the cluster. Default false for reference/test environments. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | If true, the control-plane endpoint is private-only (no public endpoint) - requires VPN/bastion/IAP for kubectl/Terraform k8s providers to reach it. Default false keeps a public endpoint (lock it down with master\_authorized\_networks); nodes are private either way. | `bool` | `false` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for the default node pool. | `string` | `"e2-standard-4"` | no |
| <a name="input_master_authorized_networks"></a> [master\_authorized\_networks](#input\_master\_authorized\_networks) | CIDRs allowed to reach the (public) control-plane endpoint. List of objects { cidr\_block, display\_name }. Empty = no restriction. | `list(object({ cidr_block = string, display_name = string }))` | `[]` | no |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | Private control-plane /28 CIDR. Must not overlap the VPC subnet/pod/service ranges or any peered network. Pass the same value to tf-dt-vpc control\_plane\_cidr to open the webhook firewall. | `string` | `"172.16.0.0/28"` | no |
| <a name="input_max_node_count"></a> [max\_node\_count](#input\_max\_node\_count) | Maximum nodes in the default pool (per zone for regional clusters). | `number` | `3` | no |
| <a name="input_min_node_count"></a> [min\_node\_count](#input\_min\_node\_count) | Minimum nodes in the default pool (per zone for regional clusters). | `number` | `1` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC network name (tf-dt-vpc output network\_name). | `string` | n/a | yes |
| <a name="input_pods_range_name"></a> [pods\_range\_name](#input\_pods\_range\_name) | Secondary range name for pods (tf-dt-vpc output pods\_range\_name). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID the cluster is created in. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for the cluster (and for the regional control plane / node pools). | `string` | n/a | yes |
| <a name="input_regional"></a> [regional](#input\_regional) | If true, a regional cluster (control plane + nodes across zones). If false, a zonal cluster - set zones to a single zone. | `bool` | `true` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | GKE release channel (RAPID, REGULAR, STABLE). | `string` | `"REGULAR"` | no |
| <a name="input_services_range_name"></a> [services\_range\_name](#input\_services\_range\_name) | Secondary range name for services (tf-dt-vpc output services\_range\_name). | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Node subnet name (tf-dt-vpc output subnet\_name). | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | Zones for the cluster. Required (single zone) when regional = false; optional for regional. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Base64 cluster CA certificate (for the Terraform kubernetes/helm providers). |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Cluster API endpoint (for the Terraform kubernetes/helm providers). |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | GKE cluster name. |
| <a name="output_location"></a> [location](#output\_location) | Cluster location (region or zone). |
| <a name="output_node_service_account"></a> [node\_service\_account](#output\_node\_service\_account) | Email of the dedicated node service account. |
| <a name="output_workload_identity_pool"></a> [workload\_identity\_pool](#output\_workload\_identity\_pool) | Workload Identity pool (<project>.svc.id.goog). |
<!-- END_TF_DOCS -->
