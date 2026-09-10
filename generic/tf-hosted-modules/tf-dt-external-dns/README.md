# tf-dt-external-dns

Installs **external-dns** - the controller that syncs DNS records (A/CNAME) for
cluster sources to a DNS provider. Wired here for **Cloudflare** + the **Gateway
API** (`gateway-httproute` source): it reads an HTTPRoute's hostnames and its
parent Gateway's address and creates/updates the matching record automatically.

This is the piece **cert-manager does not do** - cert-manager only creates the
temporary `_acme-challenge` TXT records for DNS-01 validation; external-dns owns
the actual hostname → IP records. With `policy = sync`, records are also removed
when the source disappears (no dangling records after a teardown).

Helm-only operator module, same pattern as `tf-dt-cert-manager` / `tf-dt-keda`.

## Usage

```hcl
module "external_dns" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//generic/tf-hosted-modules/tf-dt-external-dns?ref=<tag>"

  domain_filters       = ["example.com"]            # scope to your zone
  txt_owner_id         = "sandbox-testing"          # unique per cluster
  policy               = "sync"                     # auto-create + auto-clean
  cloudflare_api_token = var.cloudflare_api_token   # Zone:DNS:Edit + Zone:Read

  depends_on = [module.gke]
}
```

With a Gateway whose `HTTPRoute` has `hostnames: [match.example.com]`, external-dns
creates `match.example.com A <gateway-ip>` once that HTTPRoute exists. (So the
record appears when the app chart that ships the HTTPRoute is deployed - not
before.)

## Notes

- **Sources:** defaults to `gateway-httproute`. The record's value comes from the
  Gateway's `status.addresses`, and the hostname from the HTTPRoute — so both must
  exist for a record to be created.
- **policy:** `upsert-only` (default, never deletes) vs `sync` (deletes records
  external-dns owns when the source is removed). Only records tracked by the TXT
  registry (`txt_owner_id`) are ever touched.
- **Token:** `create_token_secret = false` references a pre-existing (e.g.
  ESO-synced) Secret instead of putting the token in TF state.
- Uses `helm_release` + `kubernetes_secret` (not `kubernetes_manifest`), so it
  applies in a single apply alongside the cluster with exec provider auth.
- Pin/raise `chart_version` as needed; verified against chart `1.15.2`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.9 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.9 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.cloudflare_api_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the external-dns Helm chart (kubernetes-sigs.github.io/external-dns). | `string` | `"1.15.2"` | no |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | Cloudflare API token (Zone:DNS:Edit + Zone:Read). Required when create\_token\_secret = true. Passed into the token Secret (lands in TF state). | `string` | `null` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create var.namespace (dedicated to external-dns). Set false to manage it elsewhere. | `bool` | `true` | no |
| <a name="input_create_token_secret"></a> [create\_token\_secret](#input\_create\_token\_secret) | Create the Cloudflare API token Secret from cloudflare\_api\_token. Set false to reference a pre-existing (e.g. ESO-synced) secret — keeps the token out of TF state. | `bool` | `true` | no |
| <a name="input_dns_provider"></a> [dns\_provider](#input\_dns\_provider) | external-dns provider (--provider). cloudflare is the only one wired for token auth here; others need their own creds. | `string` | `"cloudflare"` | no |
| <a name="input_domain_filters"></a> [domain\_filters](#input\_domain\_filters) | Zones external-dns is allowed to manage (--domain-filter), e.g. ["example.com"]. Strongly recommended to scope it. | `list(string)` | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Install external-dns. false = create nothing. | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to install external-dns into. | `string` | `"external-dns"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Record lifecycle (--policy): upsert-only (never delete) or sync (delete records when the source is removed — enables auto-cleanup on teardown). Only affects records external-dns owns (tracked via the TXT registry). | `string` | `"upsert-only"` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Extra Helm values for the external-dns chart, merged over the module defaults (deep-merged by Helm). | `any` | `{}` | no |
| <a name="input_sources"></a> [sources](#input\_sources) | external-dns sources (--source). gateway-httproute reads HTTPRoutes + their parent Gateway's address. Add service/ingress/gateway-grpcroute etc. as needed. | `list(string)` | <pre>[<br/>  "gateway-httproute"<br/>]</pre> | no |
| <a name="input_token_secret_key"></a> [token\_secret\_key](#input\_token\_secret\_key) | Key within token\_secret\_name holding the token. | `string` | `"api-token"` | no |
| <a name="input_token_secret_name"></a> [token\_secret\_name](#input\_token\_secret\_name) | Name of the Secret holding the Cloudflare API token (mounted as CF\_API\_TOKEN). | `string` | `"cloudflare-api-token"` | no |
| <a name="input_txt_owner_id"></a> [txt\_owner\_id](#input\_txt\_owner\_id) | Owner ID for the TXT-registry ownership records (--txt-owner-id). Make it unique per cluster so multiple external-dns instances don't fight over the same zone. | `string` | `"external-dns"` | no |
| <a name="input_values"></a> [values](#input\_values) | Raw Helm values documents (YAML strings) appended last. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace external-dns is installed in. |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Name of the external-dns Helm release (null when disabled). |
<!-- END_TF_DOCS -->
