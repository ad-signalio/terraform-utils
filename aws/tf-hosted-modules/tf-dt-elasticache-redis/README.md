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
| <a name="module_elasticache_redis"></a> [elasticache\_redis](#module\_elasticache\_redis) | terraform-aws-modules/elasticache/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.redis_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.redis_url_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az"></a> [az](#input\_az) | The single availability zone to use | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_create_aws_secret"></a> [create\_aws\_secret](#input\_create\_aws\_secret) | Create a secret with the rds config to AWS Secrets Manager | `bool` | `true` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The environment name (e.g., sbox-adsignal-shared-us1) | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet IDs | `any` | n/a | yes |
| <a name="input_secret_naming_convention"></a> [secret\_naming\_convention](#input\_secret\_naming\_convention) | Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The VPC configuration | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_endpoint"></a> [primary\_endpoint](#output\_primary\_endpoint) | n/a |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | n/a |
| <a name="output_redis"></a> [redis](#output\_redis) | n/a |
| <a name="output_redis_secret_name"></a> [redis\_secret\_name](#output\_redis\_secret\_name) | n/a |
<!-- END_TF_DOCS -->