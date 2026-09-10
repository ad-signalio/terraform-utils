<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.70 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.70 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_ingress_class_v1.match_alb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_class_v1) | resource |
| [kubernetes_manifest.match_alb_ingress_class_params](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_eks_clusters.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_clusters) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_certificate_arns"></a> [certificate\_arns](#input\_certificate\_arns) | ACM certificate ARNs for Ingresses using this IngressClass. Must be in the load balancer's own region. Takes precedence over certificate\_domain. | `list(string)` | `[]` | no |
| <a name="input_certificate_domain"></a> [certificate\_domain](#input\_certificate\_domain) | Instead of certificate\_arns, look up an ISSUED certificate by domain -- e.g. "*.example.com". Resolved in the provider's region. Ignored if certificate\_arns is set. | `string` | `""` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The environment name (e.g., sbox-adsignal-shared-us1) | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy for the HTTPS listener, e.g. ELBSecurityPolicy-TLS13-1-2-2021-06. Left to the controller's default when empty. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the AWS resources the ALB controller provisions for Ingresses using<br/>this IngressClass -- the load balancer, target groups and security groups.<br/><br/>These cannot be tagged by terraform: the controller creates them, not us. Set<br/>on IngressClassParams rather than as an Ingress annotation because EKS Auto<br/>Mode's controller does not honour the standard alb.ingress.kubernetes.io<br/>annotations. | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->