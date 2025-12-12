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
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [kubernetes_persistent_volume.shared_storage](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume) | resource |
| [kubernetes_storage_class_v1.match_shared_storage](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone_name"></a> [availability\_zone\_name](#input\_availability\_zone\_name) | For One Zone file systems, specify the AWS Availability Zone in which to create the file system. | `string` | `"us-east-1a"` | no |
| <a name="input_cluster_name_prefix"></a> [cluster\_name\_prefix](#input\_cluster\_name\_prefix) | Cluster name and prefix for all the associated resources | `string` | n/a | yes |
| <a name="input_eks_cluster_certificate"></a> [eks\_cluster\_certificate](#input\_eks\_cluster\_certificate) | The base64 encoded certificate for the EKS cluster. | `string` | n/a | yes |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | The endpoint for the EKS cluster. | `string` | n/a | yes |
| <a name="input_eks_cluster_token"></a> [eks\_cluster\_token](#input\_eks\_cluster\_token) | The authentication token for the EKS cluster. | `string` | n/a | yes |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The environment name (e.g., sbox-adsignal-shared-us1) | `string` | n/a | yes |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | ID of the node shared security group | `string` | n/a | yes |
| <a name="input_private_subnet"></a> [private\_subnet](#input\_private\_subnet) | Id of private subnet CIDR block, in the AZ zone specified | `string` | n/a | yes |
| <a name="input_storage_shared_storage_claim_name"></a> [storage\_shared\_storage\_claim\_name](#input\_storage\_shared\_storage\_claim\_name) | Name of the storage claim | `string` | n/a | yes |
| <a name="input_storage_shared_storage_size"></a> [storage\_shared\_storage\_size](#input\_storage\_shared\_storage\_size) | Size of the shared storage | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->