<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_argocd"></a> [argocd](#requirement\_argocd) | 7.11.2 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.11.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | git::https://github.com/ad-signalio/terraform-utils-private.git//generic/tf-hosted-modules/tf-dt-argocd | v1.0.8 |
| <a name="module_external_dns_iam"></a> [external\_dns\_iam](#module\_external\_dns\_iam) | git::https://github.com/ad-signalio/terraform-utils-private.git//aws/tf-hosted-modules/tf-dt-eks-aws-external-dns-ctrlr-iam | v1.0.0 |
| <a name="module_github"></a> [github](#module\_github) | git::https://github.com/ad-signalio/terraform-utils-private.git//generic/tf-hosted-modules/tf-dt-github | v1.0.17 |
| <a name="module_load_testing_iam"></a> [load\_testing\_iam](#module\_load\_testing\_iam) | git::https://github.com/ad-signalio/terraform-utils-private.git//aws/tf-hosted-modules/tf-dt-iam-extras | v0.0.29-aws-tf-hosted-modules-tf-dt-iam-extras |

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_namespace_v1.match](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret.dockerconfig](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_api_secret_name"></a> [api\_secret\_name](#input\_api\_secret\_name) | Name of the AWS Secrets Manager secret for API credentials. | `string` | n/a | yes |
| <a name="input_dockerconfig_json"></a> [dockerconfig\_json](#input\_dockerconfig\_json) | Base64 encoded dockerconfigjson for pulling images from private registries | `string` | `"{}"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Names of domain name to associate with the load balancer if on route53 | `string` | n/a | yes |
| <a name="input_eks_cluster"></a> [eks\_cluster](#input\_eks\_cluster) | The target EKS cluster object | `any` | n/a | yes |
| <a name="input_eks_cluster_auth"></a> [eks\_cluster\_auth](#input\_eks\_cluster\_auth) | The target EKS cluster auth object | `any` | n/a | yes |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | The environment name (e.g., sbox-adsignal-shared-us1) | `string` | n/a | yes |
| <a name="input_environment_size"></a> [environment\_size](#input\_environment\_size) | Environment size: small, medium, or large | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub token for authentication | `string` | n/a | yes |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Kubernetes namespace for the application | `string` | `"match"` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | The ARN of the OIDC provider for the EKS cluster | `string` | `null` | no |
| <a name="input_organisation_name"></a> [organisation\_name](#input\_organisation\_name) | Name of the initial Org to use match | `string` | n/a | yes |
| <a name="input_owning_user_email"></a> [owning\_user\_email](#input\_owning\_user\_email) | Email of the Admin user to access Match. | `string` | n/a | yes |
| <a name="input_rds_pg_secret_name"></a> [rds\_pg\_secret\_name](#input\_rds\_pg\_secret\_name) | Name of the AWS Secrets Manager secret for RDS Postgres. | `string` | n/a | yes |
| <a name="input_redis_secret_name"></a> [redis\_secret\_name](#input\_redis\_secret\_name) | Name of the AWS Secrets Manager secret for Redis. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | Root domain name for certificate lookup | `string` | n/a | yes |
| <a name="input_secret_store_role_arn"></a> [secret\_store\_role\_arn](#input\_secret\_store\_role\_arn) | ARN of the IAM Role for Secret Store | `string` | n/a | yes |
| <a name="input_service_account_role_name"></a> [service\_account\_role\_name](#input\_service\_account\_role\_name) | The name of the IAM role for service account | `string` | n/a | yes |
| <a name="input_smtp_secret_name"></a> [smtp\_secret\_name](#input\_smtp\_secret\_name) | Name of the AWS Secrets Manager secret for SMTP. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be added to all resources | `map(string)` | <pre>{<br/>  "Environment": "",<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_use_name_prefix"></a> [use\_name\_prefix](#input\_use\_name\_prefix) | Determines whether the IAM role/policy name (`name`/`policy_name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_user_secret_name"></a> [user\_secret\_name](#input\_user\_secret\_name) | Name of the AWS Secrets Manager secret for user credentials. | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The VPC configuration | `any` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_pr"></a> [github\_pr](#output\_github\_pr) | n/a |
<!-- END_TF_DOCS -->
