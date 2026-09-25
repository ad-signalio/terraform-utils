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
| [aws_eks_access_entry.auto_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.auto_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Map of extra Cluster access entries. See terraform-aws-modules/eks/aws for details. | `map(any)` | `{}` | no |
| <a name="input_ascp_addon_version"></a> [ascp\_addon\_version](#input\_ascp\_addon\_version) | The version of the AWS Secrets Store CSI Driver Provider (ASCP) EKS add-on | `string` | `"v3.1.0-eksbuild.1"` | no |
| <a name="input_create_compute_dependent_addons"></a> [create\_compute\_dependent\_addons](#input\_create\_compute\_dependent\_addons) | Create the addons that need compute before terraform will consider them<br/>healthy: metrics-server and aws-efs-csi-driver, both Deployments.<br/><br/>Set false for the apply that creates the cluster when compute comes from<br/>custom node pools. Those are Kubernetes CRDs, so they cannot be planned<br/>until the cluster exists, which means they land in a later apply -- and<br/>these addons would otherwise sit DEGRADED with<br/>InsufficientNumberOfReplicas until the addon create timeout, failing that<br/>first apply. Leave at the default for every apply after it.<br/><br/>Only consulted under use\_auto\_mode. With managed node groups the upstream<br/>module already orders addons after the node groups. | `bool` | `true` | no |
| <a name="input_enable_cluster_creator_admin_permissions"></a> [enable\_cluster\_creator\_admin\_permissions](#input\_enable\_cluster\_creator\_admin\_permissions) | Whether to grant admin permissions to the user who creates the cluster. Default is true. | `bool` | `false` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The environment name (e.g., sbox-adsignal-shared-us1) | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version for the EKS cluster | `string` | `"1.34"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of compute nodes for the EKS cluster | `number` | `1` | no |
| <a name="input_node_instance_type"></a> [node\_instance\_type](#input\_node\_instance\_type) | Instance type for EKS compute nodes | `string` | `"t3.2xlarge"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | A list of private subnet IDs for the EKS cluster | `list(string)` | n/a | yes |
| <a name="input_secret_naming_convention"></a> [secret\_naming\_convention](#input\_secret\_naming\_convention) | Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager. | `string` | `""` | no |
| <a name="input_secret_sync_namespace_service_accounts"></a> [secret\_sync\_namespace\_service\_accounts](#input_secret_sync_namespace_service_accounts) | Service accounts allowed to assume the secrets role, as "&lt;namespace&gt;:&lt;service-account&gt;".<br><br>Defaults to the adsignal-match chart's. An environment running the platform chart alongside it adds "snicketlabs:secret-sync-sa"; one running only the platform chart replaces the default outright. | `list(string)` | <pre>[<br>  "match:secret-sync-sa"<br>]</pre> | no |
| <a name="input_subnets_in_az"></a> [subnets\_in\_az](#input\_subnets\_in\_az) | A list of subnet IDs in the specified availability zone | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_use_auto_mode"></a> [use\_auto\_mode](#input\_use\_auto\_mode) | Choose to use, EKS Auto Mode. Default is true. If false, `node_count` and `node_instance_type` variables will be used to create a managed node group with specified count and instance type. | `bool` | `true` | no |
| <a name="input_use_builtin_node_pools"></a> [use\_builtin\_node\_pools](#input\_use\_builtin\_node\_pools) | Use EKS Auto Mode's built-in "system" and "general-purpose" node pools.<br/><br/>Set false when supplying custom node pools -- notably to get tags onto compute,<br/>which the built-in pools cannot do: they use the default NodeClass, which<br/>carries no tags. See the tf-dt-eks-auto-mode-nodepool module.<br/><br/>When false, this module creates the EC2 access entry the node IAM role needs,<br/>because EKS only manages node access automatically for the built-in pools. | `bool` | `false` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The CIDR block of the VPC | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the EKS cluster will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | ID of the cluster security group |
| <a name="output_eks_cluster"></a> [eks\_cluster](#output\_eks\_cluster) | n/a |
| <a name="output_eks_cluster_auth"></a> [eks\_cluster\_auth](#output\_eks\_cluster\_auth) | n/a |
| <a name="output_eks_cluster_certificate"></a> [eks\_cluster\_certificate](#output\_eks\_cluster\_certificate) | The certificate of the EKS cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | The endpoint of the EKS cluster |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | The ID of the EKS cluster |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | The name of the EKS cluster |
| <a name="output_eks_cluster_node_sg"></a> [eks\_cluster\_node\_sg](#output\_eks\_cluster\_node\_sg) | The security group ID for the EKS cluster nodes |
| <a name="output_eks_cluster_token"></a> [eks\_cluster\_token](#output\_eks\_cluster\_token) | The token to authenticate to the EKS cluster |
| <a name="output_eks_oidc_arn"></a> [eks\_oidc\_arn](#output\_eks\_oidc\_arn) | The ARN of the OIDC Provider |
| <a name="output_node_iam_role_arn"></a> [node\_iam\_role\_arn](#output\_node\_iam\_role\_arn) | ARN of the EKS Auto Mode node IAM role |
| <a name="output_node_iam_role_name"></a> [node\_iam\_role\_name](#output\_node\_iam\_role\_name) | Name of the EKS Auto Mode node IAM role. A custom NodeClass references it by name. |
| <a name="output_secrets_csi_irsa_role_arn"></a> [secrets\_csi\_irsa\_role\_arn](#output\_secrets\_csi\_irsa\_role\_arn) | The ARN of the IAM Role for the Secrets CSI Driver |
<!-- END_TF_DOCS -->