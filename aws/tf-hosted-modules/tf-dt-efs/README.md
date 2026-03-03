<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.70 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.70 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_efs_file_system.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_mount_target.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [kubernetes_storage_class_v1.match_shared_storage](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appuser_id"></a> [appuser\_id](#input\_appuser\_id) | The user ID for the application user. | `string` | `"65532"` | no |
| <a name="input_cluster_name_prefix"></a> [cluster\_name\_prefix](#input\_cluster\_name\_prefix) | Cluster name and prefix for all the associated resources | `string` | n/a | yes |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The environment name (e.g., sbox-adsignal-shared-us1) | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of all private subnets, containing the full objects. | <pre>list(object({<br/>    arn                                            = string<br/>    assign_ipv6_address_on_creation                = bool<br/>    availability_zone                              = string<br/>    availability_zone_id                           = string<br/>    cidr_block                                     = string<br/>    customer_owned_ipv4_pool                       = string<br/>    enable_dns64                                   = bool<br/>    enable_lni_at_device_index                     = number<br/>    enable_resource_name_dns_a_record_on_launch    = bool<br/>    enable_resource_name_dns_aaaa_record_on_launch = bool<br/>    id                                             = string<br/>    ipv4_ipam_pool_id                              = string<br/>    ipv4_netmask_length                            = number<br/>    ipv6_cidr_block                                = string<br/>    ipv6_cidr_block_association_id                 = string<br/>    ipv6_ipam_pool_id                              = string<br/>    ipv6_native                                    = bool<br/>    ipv6_netmask_length                            = number<br/>    map_customer_owned_ip_on_launch                = bool<br/>    map_public_ip_on_launch                        = bool<br/>    outpost_arn                                    = string<br/>    owner_id                                       = string<br/>    private_dns_hostname_type_on_launch            = string<br/>    region                                         = string<br/>    tags                                           = map(string)<br/>    tags_all                                       = map(string)<br/>    vpc_id                                         = string<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of VPC security group IDs to associate | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->