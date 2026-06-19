# tf-dt-gcs-active-storage (GCP)

GCS bucket for Rails Active Storage - the GCP equivalent of the AWS
`tf-dt-s3-active-storage` module. The match app's Active Storage is S3-backed
(`Service::S3StreamingService`), so on GCP it talks to the GCS **S3-interoperable
XML API** (`https://storage.googleapis.com`) using **HMAC keys** - no app code
change, the existing streaming service is reused. Native GCS (the
`GCS` Active Storage service + Workload Identity, no static key) is a possible
future goal; this module supports it too (the bucket + `objectUser` grant are
the same), but the wired path is S3-interop.

## What it creates

- **`google_storage_bucket`** `<env_name>-primary` - versioned, uniform
  bucket-level access, public-access-prevention enforced, encrypted at rest
  (Google-managed by default; customer KMS via `kms_key_name`).
- **CORS rule** for Active Storage direct uploads (PUT/GET + the same
  response headers as the S3 CORS policy), gated on `app_url`.
- **`google_storage_bucket_iam_member`** *(optional)* - grants the app's
  Workload Identity GSA `roles/storage.objectUser` on the bucket.
- **`google_storage_hmac_key`** *(optional, `create_hmac_key`)* - an HMAC key
  tied to the app GSA, for S3-interop access. Its object permissions come from
  the GSA's `objectUser` grant, so this requires `service_account_email`.
- **`google_secret_manager_secret`** *(with `create_hmac_key`)* -
  `<env_name>-gcs-hmac`, holding `{access_id, secret}` as JSON. ESO syncs it
  into the cluster's `s3` secret (`access_id` → `S3_ACCESS_KEY`,
  `secret` → `S3_SECRET_KEY`).
- **`google_project_service`** - enables `storage` always, and `secretmanager`
  when `create_hmac_key` (`disable_on_destroy = false`).

## Workload Identity dependency 

The bucket grant - and the HMAC key - are tied to the **application pod's GSA**,
which comes from the Workload Identity setup. Until that exists, leave
`service_account_email` empty (the grant is skipped, `create_hmac_key` must stay
false) - the bucket is still created. Set it once the GSA is available.

## Application config (S3-interop)

The app keeps `Service::S3StreamingService`; only the S3 endpoint + creds change.
`config/storage.yml` production block (gated on `S3_ENDPOINT` so AWS is
unaffected):

```yaml
# config/storage.yml
production:
  service: S3Streaming
  bucket: <%= ENV.fetch('S3_PRIMARY_BUCKET') %>
  endpoint: <%= ENV['S3_ENDPOINT'] %>            # https://storage.googleapis.com
  region: <%= ENV.fetch('S3_REGION', 'auto') %>
  access_key_id: <%= ENV.fetch('S3_ACCESS_KEY', nil) %>      # HMAC access_id
  secret_access_key: <%= ENV.fetch('S3_SECRET_KEY', nil) %>  # HMAC secret
  force_path_style: true
  request_checksum_calculation: when_required    # required for GCS S3-interop
```

`force_path_style` + `request_checksum_calculation: when_required` are the two
settings GCS S3-interop needs (verified with `aws-sdk-s3` against
`storage.googleapis.com`: put / multipart / presigned-GET all pass; without
`when_required` the SDK's default checksum trailer breaks uploads).

## Usage

```hcl
module "active_storage" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-gcs-active-storage?ref=<tag-or-branch>"

  project_id = var.gcp_project_id
  env_name   = var.env_id
  location   = var.region                 # co-locate with GKE to avoid egress
  app_url    = ["https://app.example.com"] # CORS origins for direct uploads

  # grant the app GSA object access AND mint the HMAC key
  # for S3-interop, stored in Secret Manager for ESO to sync.
  service_account_email = module.workload_identity.gsa_email
  create_hmac_key       = true
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

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.secretmanager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.hmac](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.hmac](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_storage_bucket.primary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.app_object_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_hmac_key.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_hmac_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_url"></a> [app\_url](#input\_app\_url) | Allowed CORS origins for Active Storage direct uploads (list of URLs). Mirrors the S3 CORS policy. Empty disables the CORS rule. | `list(string)` | `[]` | no |
| <a name="input_create_hmac_key"></a> [create\_hmac\_key](#input\_create\_hmac\_key) | Create an HMAC key for service\_account\_email and store {access\_id, secret} in Secret Manager (<env\_name>-gcs-hmac), for S3-interoperability Active Storage. Requires service\_account\_email. Default false. | `bool` | `false` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name; the bucket is named <env\_name>-primary. | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Allow Terraform to delete the bucket even if it contains objects. Default false; set true only for throwaway test envs. | `bool` | `false` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Customer-managed KMS key for encryption at rest. null uses Google-managed keys (still encrypted at rest). | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Bucket location - a region (e.g. us-central1, co-located with GKE to avoid egress) or a multi-region (e.g. US). | `string` | `"US"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID the bucket is created in. | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | App GSA (from Workload Identity) to grant roles/storage.objectUser on the bucket. Empty skips the grant (set once the GSA exists). | `string` | `""` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Enable object versioning. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the active-storage bucket (set as the GCS service bucket in config/storage.yml). |
| <a name="output_bucket_self_link"></a> [bucket\_self\_link](#output\_bucket\_self\_link) | Self link of the bucket. |
| <a name="output_bucket_url"></a> [bucket\_url](#output\_bucket\_url) | gs:// URL of the bucket. |
| <a name="output_hmac_secret_name"></a> [hmac\_secret\_name](#output\_hmac\_secret\_name) | Secret Manager secret holding the GCS HMAC {access\_id, secret} for S3-interop. null when create\_hmac\_key=false. ESO syncs this into the cluster's s3 secret. |
<!-- END_TF_DOCS -->
