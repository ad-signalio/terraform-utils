# tf-dt-vpc (GCP)

VPC networking layer for the GCP reference architecture - the GCP equivalent of
the AWS `tf-dt-vpc` module. Like the AWS module wraps `terraform-aws-modules/vpc/aws`,
this wraps the official `terraform-google-modules/network/google` and
`terraform-google-modules/cloud-nat/google` modules, adding firewall rules and
Private Service Access as the extra bits.

## What it creates

- **`terraform-google-modules/network/google`** (`~> 18.0`) — custom-mode VPC + a
  regional node subnet with `private_ip_google_access` and **secondary ranges for
  GKE pods and services** (required by VPC-native GKE).
- **`terraform-google-modules/cloud-nat/google`** (`~> 7.0`) - Cloud Router + Cloud
  NAT for outbound internet from private nodes (the AWS NAT Gateway equivalent).
- **Firewall rules** (custom-mode VPC has only implied allow-egress / deny-ingress):
  - `allow-internal` - tcp/udp/icmp between subnet + pod + service ranges
  - `allow-health-checks` - Google LB / health-check ranges (`130.211.0.0/22`, `35.191.0.0/16`)
  - `allow-iap-ssh` *(optional)* - SSH via IAP TCP forwarding
  - `allow-control-plane` *(optional)* - private GKE control plane → nodes (webhooks/metrics)
- **`google_compute_global_address` (VPC_PEERING) + `google_service_networking_connection`** -
  Private Service Access range + peering for Cloud SQL / Memorystore private IPs.

## GCP vs AWS notes

- VPCs are **global**; subnets are **regional** (one region per subnet here).
- No internet gateway resource - GCP handles egress implicitly; outbound from
  private nodes is via Cloud NAT.
- Security groups → **firewall rules** (default ingress is deny).
- NAT Gateway → **Cloud NAT** (+ Cloud Router).

## API enablement

The module enables the APIs it needs itself (`compute.googleapis.com`,
`servicenetworking.googleapis.com`) via `google_project_service`, with
`disable_on_destroy = false` so it never disables an API that sibling modules
(GKE, Filestore, Cloud SQL) also rely on. Enabling is idempotent, so multiple
modules enabling the same API is harmless. The project itself must already have
`serviceusage` + `cloudresourcemanager` enabled (done by the gcp-foundation
bootstrap) for Terraform to manage services at all.

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-vpc?ref=<tag-or-branch>"

  project_id = "my-gcp-project"
  env_name   = "sbox-adsignal-shared-us1"
  region     = "us-central1"
  # CIDRs default to sensible values; override if they collide with peers.
}
```

Downstream modules consume `network_name`, `subnet_name`, `pods_range_name`,
`services_range_name` (GKE) and `private_vpc_connection` (Cloud SQL / Memorystore,
as a `depends_on`).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_nat"></a> [cloud\_nat](#module\_cloud\_nat) | terraform-google-modules/cloud-nat/google | ~> 7.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 18.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_control_plane](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_health_checks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_iap_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_address.psa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_networking_connection.psa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_control_plane_cidr"></a> [control\_plane\_cidr](#input\_control\_plane\_cidr) | GKE private control-plane CIDR (master\_ipv4\_cidr). When set, a firewall rule allows it to reach nodes for webhooks/metrics. Leave empty to skip. | `string` | `""` | no |
| <a name="input_enable_iap_ssh"></a> [enable\_iap\_ssh](#input\_enable\_iap\_ssh) | Allow SSH from Google's IAP TCP-forwarding range (35.235.240.0/20) to instances in the VPC. | `bool` | `false` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The environment name (e.g., sbox-adsignal-shared-us1). Used as the base name for VPC resources. | `string` | n/a | yes |
| <a name="input_pods_cidr"></a> [pods\_cidr](#input\_pods\_cidr) | Secondary range for GKE pods (VPC-native cluster). Must be large - one /24 per node by default. | `string` | `"10.4.0.0/14"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID the VPC resources are created in (required by the upstream network module). | `string` | n/a | yes |
| <a name="input_psa_prefix_length"></a> [psa\_prefix\_length](#input\_psa\_prefix\_length) | Prefix length of the Private Service Access range reserved for Google-managed services (Cloud SQL, Memorystore private IP). | `number` | `16` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the (regional) subnet, Cloud Router and Cloud NAT. | `string` | n/a | yes |
| <a name="input_services_cidr"></a> [services\_cidr](#input\_services\_cidr) | Secondary range for GKE services (VPC-native cluster). | `string` | `"10.8.0.0/20"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | Primary CIDR of the GKE node subnet. | `string` | `"10.0.0.0/20"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | VPC network ID (for use by the GKE and Cloud SQL modules). |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | VPC network name. |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | VPC network self link. |
| <a name="output_pods_range_name"></a> [pods\_range\_name](#output\_pods\_range\_name) | Name of the secondary range for GKE pods (VPC-native cluster). |
| <a name="output_private_vpc_connection"></a> [private\_vpc\_connection](#output\_private\_vpc\_connection) | Service networking connection ID (depend on this from Cloud SQL / Memorystore to ensure peering exists first). |
| <a name="output_psa_range_name"></a> [psa\_range\_name](#output\_psa\_range\_name) | Name of the reserved Private Service Access range. |
| <a name="output_services_range_name"></a> [services\_range\_name](#output\_services\_range\_name) | Name of the secondary range for GKE services (VPC-native cluster). |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Node subnet ID. |
| <a name="output_subnet_name"></a> [subnet\_name](#output\_subnet\_name) | Node subnet name (needed by the GKE module). |
| <a name="output_subnet_self_link"></a> [subnet\_self\_link](#output\_subnet\_self\_link) | Node subnet self link. |
<!-- END_TF_DOCS -->
