<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.70 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.70 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.eks_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_security_group.eks_cluster_node_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ad_signal_region"></a> [ad\_signal\_region](#input\_ad\_signal\_region) | The Ad Signal region (e.g., us1, eu1, ap1) | `string` | n/a | yes |
| <a name="input_cust_id"></a> [cust\_id](#input\_cust\_id) | The customer or tenant environment name, eg adsignal, adsignalperf | `string` | n/a | yes |
| <a name="input_env_type"></a> [env\_type](#input\_env\_type) | The environment type (e.g., dedicated, shared) | `string` | n/a | yes |
| <a name="input_env_use"></a> [env\_use](#input\_env\_use) | The environment type (e.g., prod, test, uat, sbox) | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_eks_cluster_certificate"></a> [eks\_cluster\_certificate](#output\_eks\_cluster\_certificate) | The ID of the EKS cluster |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | The ID of the EKS cluster |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | The ID of the EKS cluster |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | The name of the EKS cluster |
| <a name="output_eks_cluster_node_sg"></a> [eks\_cluster\_node\_sg](#output\_eks\_cluster\_node\_sg) | The security group ID for the EKS cluster nodes |
| <a name="output_eks_cluster_token"></a> [eks\_cluster\_token](#output\_eks\_cluster\_token) | The token to authenticate to the EKS cluster |
| <a name="output_eks_oidc_arn"></a> [eks\_oidc\_arn](#output\_eks\_oidc\_arn) | The ARN of the OIDC Provider |
<!-- END_TF_DOCS -->