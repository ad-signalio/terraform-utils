# tf-dt-cert-manager-cloudflare-issuer

A cert-manager **ACME `(Cluster)Issuer`** that solves **DNS-01** challenges via
**Cloudflare**, plus the Cloudflare API token `Secret` it reads. This is the
*issuer config* layer — it pairs with `tf-dt-cert-manager` (the operator) and is
consumed by `Certificate` resources (e.g. the helm-match chart's
`certificate.enabled`).

Cloud-agnostic: works on any cluster running cert-manager (GKE, EKS, on-prem),
regardless of where the workload's load balancer lives.

## Usage

```hcl
module "cert_manager_issuer" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//generic/tf-hosted-modules/tf-dt-cert-manager-cloudflare-issuer?ref=<tag>"

  cluster_issuer_name  = "letsencrypt-prod"
  acme_email           = "infra@example.com"
  cloudflare_api_token = var.cloudflare_api_token  # scoped Zone:DNS:Edit + Zone:Read

  depends_on = [module.cert_manager] # operator + CRDs must exist first
}
```

Then reference it from a `Certificate` (or the chart): `issuerRef.name =
module.cert_manager_issuer.cluster_issuer_name`, `kind = ClusterIssuer`.

### Keeping the token out of state (recommended for prod)

```hcl
  create_token_secret = false          # don't create the Secret here
  token_secret_name   = "cloudflare-api-token"  # a pre-existing (e.g. ESO-synced) Secret
  token_secret_key    = "api-token"
```

With `create_token_secret = false` the module only creates the Issuer and reads
an externally-managed Secret, so the token never enters Terraform state.

## Notes

- Uses `kubernetes_manifest`, which needs the cluster reachable and the
  **cert-manager CRDs present at plan time**. Apply after the cert-manager
  operator (staged apply on a fresh cluster).
- Default `acme_server` is Let's Encrypt **production**. Use the staging URL
  (`https://acme-staging-v02.api.letsencrypt.org/directory`) while iterating to
  avoid rate limits, then switch to prod.
- `dns_zones` optionally restricts the solver to specific zones
  (`solver.selector.dnsZones`); empty solves for all zones.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.issuer](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_secret.cloudflare_api_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_account_key_secret_name"></a> [account\_key\_secret\_name](#input\_account\_key\_secret\_name) | Name of the Secret cert-manager stores the ACME account private key in. Defaults to "<cluster\_issuer\_name>-account-key". | `string` | `null` | no |
| <a name="input_acme_email"></a> [acme\_email](#input\_acme\_email) | Email for the ACME account (Let's Encrypt expiry notices). | `string` | n/a | yes |
| <a name="input_acme_server"></a> [acme\_server](#input\_acme\_server) | ACME directory URL. Default = Let's Encrypt production. Staging = https://acme-staging-v02.api.letsencrypt.org/directory. | `string` | `"https://acme-v02.api.letsencrypt.org/directory"` | no |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | Cloudflare API token (scoped Zone:DNS:Edit + Zone:Read) for the DNS-01 solver. Required when create\_token\_secret = true. NOTE: stored in Terraform state — prefer create\_token\_secret = false + an ESO-synced secret for production. | `string` | `null` | no |
| <a name="input_cluster_issuer_name"></a> [cluster\_issuer\_name](#input\_cluster\_issuer\_name) | Name of the (Cluster)Issuer. Referenced by Certificate issuerRef.name. | `string` | `"letsencrypt-prod"` | no |
| <a name="input_create_token_secret"></a> [create\_token\_secret](#input\_create\_token\_secret) | Create the Cloudflare API token Secret from cloudflare\_api\_token. Set false to reference a pre-existing secret (e.g. ESO-synced) named token\_secret\_name with key token\_secret\_key — keeps the token out of Terraform state. | `bool` | `true` | no |
| <a name="input_dns_zones"></a> [dns\_zones](#input\_dns\_zones) | Optional DNS zones the Cloudflare solver is restricted to (solver selector.dnsZones). Empty = solve for all zones. | `list(string)` | `[]` | no |
| <a name="input_issuer_kind"></a> [issuer\_kind](#input\_issuer\_kind) | ClusterIssuer (cluster-wide) or Issuer (namespaced). Issuer is created in var.namespace. | `string` | `"ClusterIssuer"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Cloudflare token Secret (and the Issuer when issuer\_kind = Issuer). Must be where cert-manager can read the secret. | `string` | `"cert-manager"` | no |
| <a name="input_token_secret_key"></a> [token\_secret\_key](#input\_token\_secret\_key) | Key within token\_secret\_name holding the token value. | `string` | `"api-token"` | no |
| <a name="input_token_secret_name"></a> [token\_secret\_name](#input\_token\_secret\_name) | Name of the Secret holding the Cloudflare API token. | `string` | `"cloudflare-api-token"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_issuer_name"></a> [cluster\_issuer\_name](#output\_cluster\_issuer\_name) | Name of the created (Cluster)Issuer. Use as Certificate issuerRef.name. |
| <a name="output_issuer_kind"></a> [issuer\_kind](#output\_issuer\_kind) | Kind of the created issuer (ClusterIssuer or Issuer). Use as Certificate issuerRef.kind. |
| <a name="output_token_secret_name"></a> [token\_secret\_name](#output\_token\_secret\_name) | Name of the Cloudflare API token Secret the issuer reads. |
<!-- END_TF_DOCS -->
