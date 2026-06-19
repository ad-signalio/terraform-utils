# tf-dt-memorystore (GCP)

Memorystore for Redis - the GCP equivalent of the AWS `tf-dt-elasticache-redis`
module. Like that module wraps `terraform-aws-modules/elasticache/aws`, this
wraps the official `terraform-google-modules/memorystore/google`, with a Secret
Manager secret as the extra bit. The Redis protocol is identical, so no
application changes are needed.

## Connection pattern: Private Service Access

`connect_mode = PRIVATE_SERVICE_ACCESS` - the instance gets a private IP from the
VPC's reserved PSA range (same peering Cloud SQL uses). Pods connect directly,
like ElastiCache today. No extra VPC firewall rule is needed: GCP's implied
allow-egress lets GKE nodes reach the instance over the peering.

## What it creates

- **`terraform-google-modules/memorystore/google`** (`~> 16.0`) - a
  `google_redis_instance` (Redis, AUTH enabled by default).
- **`google_secret_manager_secret` (+ version)** - connection JSON
  (`host`/`port`/`auth`/`url`).
- **`google_project_service`** - enables `redis` + `secretmanager`
  (`disable_on_destroy = false`).

## Requirements

- `tf-dt-vpc` applied first - pass its `network_self_link` (→ `network`) and
  `psa_range_name` (→ `reserved_ip_range`). Use the **self-link**, not `network_id`
  (see the tf-dt-vpc PSA note re: project-form stability).
- The PSA peering must exist before the private IP can be allocated
  (`depends_on = [module.vpc]` at the env level).

## Usage

```hcl
module "memorystore" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-memorystore?ref=<tag-or-branch>"

  project_id        = var.gcp_project_id
  env_name          = var.env_id
  region            = var.region
  tier              = "BASIC" # or STANDARD_HA per sizing profile
  memory_size_gb    = 1
  network           = module.vpc.network_self_link
  reserved_ip_range = module.vpc.psa_range_name

  depends_on = [module.vpc]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_redis"></a> [redis](#module\_redis) | terraform-google-modules/memorystore/google | ~> 16.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auth_enabled"></a> [auth\_enabled](#input\_auth\_enabled) | Enable Redis AUTH (generates an auth string). | `bool` | `true` | no |
| <a name="input_create_secret"></a> [create\_secret](#input\_create\_secret) | Store the Redis connection URL/details in GCP Secret Manager. | `bool` | `true` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name; base for the instance and secret names. | `string` | n/a | yes |
| <a name="input_memory_size_gb"></a> [memory\_size\_gb](#input\_memory\_size\_gb) | Redis memory size in GiB. | `number` | `1` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC network self-link for authorized\_network (tf-dt-vpc output network\_self\_link - use the self-link, not network\_id; see tf-dt-vpc PSA note). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID the Memorystore instance is created in. | `string` | n/a | yes |
| <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version) | Redis version (e.g. REDIS\_7\_2). | `string` | `"REDIS_7_2"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the Memorystore instance. | `string` | n/a | yes |
| <a name="input_reserved_ip_range"></a> [reserved\_ip\_range](#input\_reserved\_ip\_range) | Name of the reserved Private Service Access range (tf-dt-vpc output psa\_range\_name) for PRIVATE\_SERVICE\_ACCESS connect mode. null lets Google pick. | `string` | `null` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | Service tier: BASIC (single node) or STANDARD\_HA (replicated). Set per sizing profile in tfvars. | `string` | `"BASIC"` | no |
| <a name="input_transit_encryption_mode"></a> [transit\_encryption\_mode](#input\_transit\_encryption\_mode) | In-transit encryption: DISABLED or SERVER\_AUTHENTICATION. | `string` | `"DISABLED"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_host"></a> [host](#output\_host) | Memorystore private IP (Redis host). |
| <a name="output_port"></a> [port](#output\_port) | Redis port. |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | Secret Manager secret with the Redis connection details (null if create\_secret = false). |
<!-- END_TF_DOCS -->
