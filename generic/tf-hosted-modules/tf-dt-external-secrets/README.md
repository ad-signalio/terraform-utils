# tf-dt-external-secrets

Installs the [External Secrets Operator](https://external-secrets.io/) (controller
+ CRDs) via Helm - the operator that powers the GCP secrets path (sc-22517).
Follows the `tf-dt-keda` pattern.

This module installs **only the operator**. The `SecretStore` and `ExternalSecret`
resources are deployed separately by the `secrets-configuration/eso-support` Helm
chart, and the operator's Workload Identity binding is wired via
`tf-dt-workload-identity` (sc-22516).

Cloud-agnostic - ESO runs on any Kubernetes cluster (AWS/GCP/bare metal); the
per-cloud difference lives in the `SecretStore`, not here.

## Usage

```hcl
module "external_secrets" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//generic/tf-hosted-modules/tf-dt-external-secrets?ref=<tag-or-branch>"

  depends_on = [module.gke]
}
```

Requires a `helm` provider configured against the cluster.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.external_secrets](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the external-secrets Helm chart. | `string` | `"2.6.0"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to install the External Secrets Operator. | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to install ESO into (created if absent). | `string` | `"external-secrets"` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Additional settings merged into the Helm values (override module defaults). | `map(any)` | `{}` | no |
| <a name="input_values"></a> [values](#input\_values) | List of raw YAML value documents passed to the Helm release. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the External Secrets Operator is installed into. |
<!-- END_TF_DOCS -->
