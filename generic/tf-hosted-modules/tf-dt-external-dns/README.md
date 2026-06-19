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
## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| enabled | Install external-dns. | `bool` | `true` |
| chart_version | external-dns Helm chart version. | `string` | `"1.15.2"` |
| namespace | Namespace to install into. | `string` | `"external-dns"` |
| create_namespace | Create the namespace. | `bool` | `true` |
| dns_provider | external-dns --provider. | `string` | `"cloudflare"` |
| sources | external-dns --source list. | `list(string)` | `["gateway-httproute"]` |
| domain_filters | Zones to manage (--domain-filter). | `list(string)` | `[]` |
| policy | upsert-only or sync. | `string` | `"upsert-only"` |
| txt_owner_id | TXT-registry owner id. | `string` | `"external-dns"` |
| cloudflare_api_token | Cloudflare API token. | `string` | `null` |
| create_token_secret | Create the token Secret. | `bool` | `true` |
| token_secret_name | Token Secret name. | `string` | `"cloudflare-api-token"` |
| token_secret_key | Token Secret key. | `string` | `"api-token"` |
| settings | Extra Helm values (map). | `any` | `{}` |
| values | Raw Helm values docs. | `list(string)` | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Namespace external-dns is in. |
| release_name | Helm release name (null when disabled). |
<!-- END_TF_DOCS -->
