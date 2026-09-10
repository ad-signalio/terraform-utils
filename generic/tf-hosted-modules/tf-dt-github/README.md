<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.11.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_github"></a> [github](#provider\_github) | 6.11.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_repository_file.cluster_config](https://registry.terraform.io/providers/integrations/github/6.11.0/docs/resources/repository_file) | resource |
| [github_repository_file.values_yaml](https://registry.terraform.io/providers/integrations/github/6.11.0/docs/resources/repository_file) | resource |
| [github_repository_pull_request.this](https://registry.terraform.io/providers/integrations/github/6.11.0/docs/resources/repository_pull_request) | resource |
| [random_pet.branch_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [github_repository_file.env_yaml](https://registry.terraform.io/providers/integrations/github/6.11.0/docs/data-sources/repository_file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_api_secret_name"></a> [api\_secret\_name](#input\_api\_secret\_name) | Name of the AWS Secrets Manager secret for API credentials. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain that the app is hosted, dns, app settings, etc. | `string` | n/a | yes |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | EKS cluster endpoint | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | EKS cluster name | `string` | n/a | yes |
| <a name="input_environment_size"></a> [environment\_size](#input\_environment\_size) | Environment size: small, medium, or large | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub token for authentication | `string` | n/a | yes |
| <a name="input_organisation_name"></a> [organisation\_name](#input\_organisation\_name) | Name of the initial Org to use match | `string` | n/a | yes |
| <a name="input_owning_user_email"></a> [owning\_user\_email](#input\_owning\_user\_email) | Email of the Admin user to access Match. | `string` | n/a | yes |
| <a name="input_rds_pg_secret_name"></a> [rds\_pg\_secret\_name](#input\_rds\_pg\_secret\_name) | Name of the AWS Secrets Manager secret for RDS Postgres. | `string` | n/a | yes |
| <a name="input_redis_secret_name"></a> [redis\_secret\_name](#input\_redis\_secret\_name) | Name of the AWS Secrets Manager secret for Redis. | `string` | n/a | yes |
| <a name="input_secret_store_role_arn"></a> [secret\_store\_role\_arn](#input\_secret\_store\_role\_arn) | ARN of the IAM Role for Secret Store | `string` | n/a | yes |
| <a name="input_smtp_secret_name"></a> [smtp\_secret\_name](#input\_smtp\_secret\_name) | Name of the AWS Secrets Manager secret for SMTP. | `string` | n/a | yes |
| <a name="input_user_secret_name"></a> [user\_secret\_name](#input\_user\_secret\_name) | Name of the AWS Secrets Manager secret for user credentials. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the EKS cluster is deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_pr"></a> [github\_pr](#output\_github\_pr) | n/a |
<!-- END_TF_DOCS -->
