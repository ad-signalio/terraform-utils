<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.deployment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.irsa_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.deployment_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_policy_arns"></a> [attach\_policy\_arns](#input\_attach\_policy\_arns) | List of IAM policy ARNs to attach to the IAM role (managed policies) | `list(string)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the existing EKS cluster | `string` | n/a | yes |
| <a name="input_eks_cluster"></a> [eks\_cluster](#input\_eks\_cluster) | The target EKS cluster object | `any` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role to create | `string` | `null` | no |
| <a name="input_inline_role_policy"></a> [inline\_role\_policy](#input\_inline\_role\_policy) | Optional JSON inline policy to attach to the role (as a single policy document). Leave null to skip. | `string` | `null` | no |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Kubernetes namespace for the ServiceAccount | `string` | `"default"` | no |
| <a name="input_k8s_service_account_name"></a> [k8s\_service\_account\_name](#input\_k8s\_service\_account\_name) | Kubernetes ServiceAccount name to associate with the IAM role | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | The arn of the OIDC provider | `string` | n/a | yes |
| <a name="input_secret_naming_convention"></a> [secret\_naming\_convention](#input\_secret\_naming\_convention) | Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be added to all resources | `map(string)` | <pre>{<br/>  "Environment": "",<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role. |
<!-- END_TF_DOCS -->