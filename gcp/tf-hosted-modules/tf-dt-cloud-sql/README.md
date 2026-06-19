# tf-dt-cloud-sql (GCP)

Cloud SQL for PostgreSQL - the GCP equivalent of the AWS `tf-dt-rds-pg` module.
Like that module wraps `terraform-aws-modules/rds/aws`, this wraps the official
`terraform-google-modules/sql-db/google//modules/postgresql`, with a generated
password and a Secret Manager secret as the extra bits.

## Connection pattern: Private Service Access (no Auth Proxy)

The instance has **private IP only** (`ipv4_enabled = false`) drawn from the
reserved Private Service Access range created by `tf-dt-vpc`. Pods connect
directly to that IP on 5432 - exactly like RDS today - so **no Cloud SQL Auth
Proxy sidecar** is needed and helm-match stays cloud-agnostic.

No extra VPC firewall rule is required: GCP's implied allow-egress lets GKE
nodes reach the instance over the service-networking peering.

## What it creates

- **`terraform-google-modules/sql-db//modules/postgresql`** (`~> 28.0`) -
  PostgreSQL instance (private IP, `ssl_mode = ENCRYPTED_ONLY`), the application
  database, and the application user (password from `random_password`).
- **`google_secret_manager_secret` (+ version)** - connection JSON
  (`host`/`port`/`dbname`/`username`/`password`/`connection_name`).
- **`google_project_service`** - enables `sqladmin` + `secretmanager`
  (`disable_on_destroy = false`).

## Requirements

- Consuming environment must configure **both `google` and `google-beta`** providers
  (the upstream module uses google-beta).
- `tf-dt-vpc` applied first - pass its `network_id` (→ `private_network`) and
  `psa_range_name` (→ `allocated_ip_range`). The PSA peering must exist before the
  private IP can be allocated (`depends_on = [module.vpc]` at the env level).

## Notes

- `random_instance_name = true` by default - Cloud SQL names can't be reused for
  ~1 week after deletion, which otherwise breaks repeated create/destroy in test envs.
- `deletion_protection` defaults `false` for reference/test environments.

## Usage

```hcl
module "cloud_sql" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-cloud-sql?ref=<tag-or-branch>"

  project_id         = var.gcp_project_id
  env_name           = var.env_id
  region             = var.region
  tier               = "db-custom-4-15360" # per sizing profile
  private_network    = module.vpc.network_id
  allocated_ip_range = module.vpc.psa_range_name

  depends_on = [module.vpc]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.22, < 8 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 7.22, < 8 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.35.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_postgresql"></a> [postgresql](#module\_postgresql) | terraform-google-modules/sql-db/google//modules/postgresql | ~> 28.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [random_password.db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_ip_range"></a> [allocated\_ip\_range](#input\_allocated\_ip\_range) | Name of the reserved Private Service Access range to draw the private IP from (tf-dt-vpc output psa\_range\_name). null lets Google pick any PSA range. | `string` | `null` | no |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type) | ZONAL (single zone) or REGIONAL (HA). | `string` | `"ZONAL"` | no |
| <a name="input_create_secret"></a> [create\_secret](#input\_create\_secret) | Store connection details (host, port, db, user, password) in GCP Secret Manager. | `bool` | `true` | no |
| <a name="input_database_flags"></a> [database\_flags](#input\_database\_flags) | List of Cloud SQL database flags ({ name, value }). | `list(object({ name = string, value = string }))` | `[]` | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | Cloud SQL PostgreSQL version (e.g. POSTGRES\_16). | `string` | `"POSTGRES_16"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Application database name. | `string` | `"match"` | no |
| <a name="input_db_user"></a> [db\_user](#input\_db\_user) | Application database user name. | `string` | `"match"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protect the instance from deletion (both the Terraform lifecycle guard and the GCP instance setting). Default false for reference/test environments. | `bool` | `false` | no |
| <a name="input_disk_autoresize"></a> [disk\_autoresize](#input\_disk\_autoresize) | Allow the data disk to grow automatically. | `bool` | `true` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Data disk size in GB. | `number` | `20` | no |
| <a name="input_edition"></a> [edition](#input\_edition) | Cloud SQL edition. ENTERPRISE matches the db-custom-N-M / db-highmem tiers in the sizing scheme; ENTERPRISE\_PLUS requires db-perf-optimized-* tiers. | `string` | `"ENTERPRISE"` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name; base for the instance and secret names. | `string` | n/a | yes |
| <a name="input_private_network"></a> [private\_network](#input\_private\_network) | VPC network self-link/id for the private IP (tf-dt-vpc output network\_id). Private IP only - ipv4\_enabled is forced false. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID the Cloud SQL instance is created in. | `string` | n/a | yes |
| <a name="input_random_instance_name"></a> [random\_instance\_name](#input\_random\_instance\_name) | Append a random suffix to the instance name. Recommended: Cloud SQL instance names can't be reused for ~1 week after deletion, which bites repeated create/destroy in test envs. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region for the Cloud SQL instance. | `string` | n/a | yes |
| <a name="input_tier"></a> [tier](#input\_tier) | Machine tier (db-custom-N-M). Set per sizing profile in tfvars (small: db-custom-4-15360, medium: db-custom-8-30720, large: db-highmem-16). | `string` | `"db-custom-2-7680"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Preferred zone for a ZONAL instance (optional). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | Application database name. |
| <a name="output_instance_connection_name"></a> [instance\_connection\_name](#output\_instance\_connection\_name) | Cloud SQL connection name (project:region:instance). |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | Cloud SQL instance name (includes the random suffix if enabled). |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP of the Cloud SQL instance (pods connect here directly). |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | Secret Manager secret holding the connection details (null if create\_secret = false). |
<!-- END_TF_DOCS -->
