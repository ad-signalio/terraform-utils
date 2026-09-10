# tf-dt-keda

Terraform module to deploy KEDA (Kubernetes Event-driven Autoscaling) on Kubernetes.

This module:
1. Downloads the KEDA CRDs from the official GitHub releases page matching the specified `chart_version`.
2. Installs the CRDs using `kubernetes_manifest` resources (server-side apply).
3. Installs the KEDA Helm chart with CRD installation disabled (to prevent conflicts).


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.9 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.9 |
| <a name="provider_http"></a> [http](#provider\_http) | >= 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.keda](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.keda_crds](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace_v1.match](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [http_http.keda_crds](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_application_namespace"></a> [application\_namespace](#input\_application\_namespace) | Name of the namespace where Keda will watch to scale workloads. | `string` | `"match"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the KEDA Helm chart | `string` | `"2.19.0"` | no |
| <a name="input_create_match_namespace"></a> [create\_match\_namespace](#input\_create\_match\_namespace) | Whether to create the Kubernetes namespace for the application (e.g., 'match') as part of this module. Set to false if the namespace is already created by another module or manually. | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to enable the KEDA module. Set to false to only install CRDs using the manifest resource. | `bool` | `true` | no |
| <a name="input_install_crds_separately"></a> [install\_crds\_separately](#input\_install\_crds\_separately) | Whether to install KEDA CRDs separately from the Helm chart (not recommended for production) | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to install KEDA | `string` | `"keda"` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Additional settings to pass to the Helm chart | `map(any)` | `{}` | no |
| <a name="input_values"></a> [values](#input\_values) | List of values in raw YAML format to pass to the helm release | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
