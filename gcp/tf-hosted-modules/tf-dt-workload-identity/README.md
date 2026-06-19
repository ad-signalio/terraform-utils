# tf-dt-workload-identity (GCP)

GKE Workload Identity binding - the GCP analogue of AWS IRSA. Wraps
the official `terraform-google-modules/kubernetes-engine//modules/workload-identity`.
Creates a GCP service account (GSA), binds it to a Kubernetes ServiceAccount
(KSA) via `roles/iam.workloadIdentityUser`, grants the GSA project roles, and
annotates the KSA with `iam.gke.io/gcp-service-account`.

## Requirements

- The consuming environment must configure a **`kubernetes` provider** pointed at
  the GKE cluster (the module manages a `kubernetes_service_account`).
- For `use_existing_k8s_sa = true`, the KSA must already exist (chart deployed first).

## Usage

```hcl

module "secrets_wi" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-workload-identity?ref=<tag-or-branch>"

  project_id   = var.gcp_project_id
  name         = "${var.env_id}-secrets"
  cluster_name = module.gke.cluster_name
  location     = module.gke.location
  namespace    = "match"
  k8s_sa_name  = "match-secrets"        # keep identical across clouds
  roles        = ["roles/secretmanager.secretAccessor"]
}

# feed the GSA email to a bucket grant :
#   service_account_email = module.active_storage_wi.gcp_service_account_email
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.17, < 8 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20, < 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.36.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_workload_identity"></a> [workload\_identity](#module\_workload\_identity) | terraform-google-modules/kubernetes-engine/google//modules/workload-identity | ~> 44.0 |

## Resources

| Name | Type |
|------|------|
| [google_project_service.required](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotate_k8s_sa"></a> [annotate\_k8s\_sa](#input\_annotate\_k8s\_sa) | Add the iam.gke.io/gcp-service-account annotation binding the KSA to the GSA. | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | GKE cluster name (used to resolve the cluster for the KSA annotation). | `string` | n/a | yes |
| <a name="input_k8s_sa_name"></a> [k8s\_sa\_name](#input\_k8s\_sa\_name) | Kubernetes ServiceAccount name. Keep this identical across clouds for chart portability. Defaults to var.name. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | GKE cluster location (region or zone). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name for the GCP service account (and the default KSA name). | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace of the service account. | `string` | `"match"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID the GSA is created in. | `string` | n/a | yes |
| <a name="input_roles"></a> [roles](#input\_roles) | Project IAM roles to grant the GSA (e.g. roles/secretmanager.secretAccessor). Bucket-scoped grants (GCS) are done on the bucket via tf-dt-gcs-active-storage instead. | `list(string)` | `[]` | no |
| <a name="input_use_existing_k8s_sa"></a> [use\_existing\_k8s\_sa](#input\_use\_existing\_k8s\_sa) | If true, annotate an existing KSA (e.g. one created by the helm-match chart) rather than create it. The chart-portable pattern: chart owns the KSA, this only adds the iam.gke.io annotation. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_service_account_email"></a> [gcp\_service\_account\_email](#output\_gcp\_service\_account\_email) | Email of the GSA. Grant this resource-scoped access (e.g. pass to tf-dt-gcs-active-storage service\_account\_email for the bucket grant). |
| <a name="output_gcp_service_account_fqn"></a> [gcp\_service\_account\_fqn](#output\_gcp\_service\_account\_fqn) | Fully-qualified GSA name (projects/.../serviceAccounts/...). |
| <a name="output_k8s_service_account_name"></a> [k8s\_service\_account\_name](#output\_k8s\_service\_account\_name) | Name of the Kubernetes ServiceAccount bound to the GSA. |
<!-- END_TF_DOCS -->
