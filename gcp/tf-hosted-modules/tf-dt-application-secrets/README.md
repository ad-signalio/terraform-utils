# tf-dt-application-secrets (GCP)

Generates the Match application's "baked-in" secrets and stores them in GCP
Secret Manager - the GCP equivalent of the AWS `tf-dt-application-secrets` module.
Consumed by External Secrets Operator which syncs them into the cluster.

## What it creates

- **`<env_name>-api-secrets`** (JSON) - Rails app secrets:
  - `secret_key_base` (random_password)
  - `api_secret_key_base` (random_id hex)
  - `ingest_credential_encryption_key` (random_id hex)
- **`<env_name>-user-password`** (JSON) - `{ password }` for the owning user
  (plus `username` if `owning_user_email` is set).
- Enables the `secretmanager` API (`disable_on_destroy = false`).

GCP Secret Manager values are stored as JSON; the ESO `ExternalSecret` extracts
individual keys via `remoteRef.property`, matching the AWS layout.

## Usage

```hcl
module "application_secrets" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-application-secrets?ref=<tag-or-branch>"

  project_id        = var.gcp_project_id
  env_name          = var.env_id
  owning_user_email = var.owning_user_email
}
```

Outputs `api_secret_name` / `user_secret_name` feed the eso-support chart's
`secretNames.api` / `secretNames.user`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.api_secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.user_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.api_secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.user_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [random_id.api_secret_key_base](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.ingest_credential_encryption_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.secret_key_base](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name; secrets are named <env\_name>-api-secrets and <env\_name>-user-password. | `string` | n/a | yes |
| <a name="input_owning_user_email"></a> [owning\_user\_email](#input\_owning\_user\_email) | Optional. If set, included as the username in the owning-user secret alongside the generated password. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID the secrets are created in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_secret_name"></a> [api\_secret\_name](#output\_api\_secret\_name) | Secret Manager secret\_id holding the Rails api-secrets (for the ESO ExternalSecret). |
| <a name="output_user_secret_name"></a> [user\_secret\_name](#output\_user\_secret\_name) | Secret Manager secret\_id holding the owning-user password (for the ESO ExternalSecret). |
<!-- END_TF_DOCS -->
