<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_ingress_class_v1.match_alb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_class_v1) | resource |
| [kubernetes_manifest.match_alb_ingress_class_params](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_certificate"></a> [eks\_cluster\_certificate](#input\_eks\_cluster\_certificate) | The base64 encoded certificate for the EKS cluster. | `string` | n/a | yes |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | The endpoint for the EKS cluster. | `string` | n/a | yes |
| <a name="input_eks_cluster_token"></a> [eks\_cluster\_token](#input\_eks\_cluster\_token) | The authentication token for the EKS cluster. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->