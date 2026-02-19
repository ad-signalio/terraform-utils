<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.70 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.70 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_csi_irsa"></a> [ebs\_csi\_irsa](#module\_ebs\_csi\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.2.1 |
| <a name="module_efs_csi_irsa"></a> [efs\_csi\_irsa](#module\_efs\_csi\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.2.1 |
| <a name="module_eks_al2023_cluster"></a> [eks\_al2023\_cluster](#module\_eks\_al2023\_cluster) | terraform-aws-modules/eks/aws | ~> 21.15.1 |
| <a name="module_secrets_csi_irsa"></a> [secrets\_csi\_irsa](#module\_secrets\_csi\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_roles.sso_permset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_access_role_names"></a> [admin\_access\_role\_names](#input\_admin\_access\_role\_names) | A list of IAM role names (NOT full ARNs) that exist in the account that will have admin access to the EKS cluster | `list(string)` | `[]` | no |
| <a name="input_admin_access_sso_permission_set_names"></a> [admin\_access\_sso\_permission\_set\_names](#input\_admin\_access\_sso\_permission\_set\_names) | A list of AWS SSO permission set names (NOT full ARNs) that exist in the account that will have admin access to the EKS cluster eg 'Infra' | `list(string)` | `[]` | no |
| <a name="input_enable_karpenter"></a> [enable\_karpenter](#input\_enable\_karpenter) | Flag to enable or disable Karpenter | `bool` | `false` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The environment name (e.g., sbox-adsignal-shared-us1) | `string` | n/a | yes |
| <a name="input_extra_access_entries"></a> [extra\_access\_entries](#input\_extra\_access\_entries) | Map of extra Cluster access entries. See  [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest#input_access_entries) for details. | `map(any)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of compute nodes for the EKS cluster | `number` | n/a | yes |
| <a name="input_node_instance_type"></a> [node\_instance\_type](#input\_node\_instance\_type) | Instance type for EKS compute nodes | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | A list of private subnet IDs for the EKS cluster | `list(string)` | n/a | yes |
| <a name="input_secret_naming_convention"></a> [secret\_naming\_convention](#input\_secret\_naming\_convention) | Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager. | `string` | `""` | no |
| <a name="input_subnets_in_az"></a> [subnets\_in\_az](#input\_subnets\_in\_az) | A list of subnet IDs in the specified availability zone | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the EKS cluster will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_cluster"></a> [eks\_cluster](#output\_eks\_cluster) | n/a |
| <a name="output_eks_cluster_auth"></a> [eks\_cluster\_auth](#output\_eks\_cluster\_auth) | n/a |
| <a name="output_eks_cluster_certificate"></a> [eks\_cluster\_certificate](#output\_eks\_cluster\_certificate) | The certificate of the EKS cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | The endpoint of the EKS cluster |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | The ID of the EKS cluster |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | The name of the EKS cluster |
| <a name="output_eks_cluster_node_sg"></a> [eks\_cluster\_node\_sg](#output\_eks\_cluster\_node\_sg) | The security group ID for the EKS cluster nodes |
| <a name="output_eks_cluster_token"></a> [eks\_cluster\_token](#output\_eks\_cluster\_token) | The token to authenticate to the EKS cluster |
| <a name="output_eks_oidc_arn"></a> [eks\_oidc\_arn](#output\_eks\_oidc\_arn) | The ARN of the OIDC Provider |
| <a name="output_secrets_csi_irsa_role_arn"></a> [secrets\_csi\_irsa\_role\_arn](#output\_secrets\_csi\_irsa\_role\_arn) | The ARN of the IAM Role for the Secrets CSI Driver |
<!-- END_TF_DOCS -->