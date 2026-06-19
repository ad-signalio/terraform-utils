# tf-dt-cert-manager-certificate

A cert-manager **`Certificate`** - requests a TLS cert from an `Issuer`/
`ClusterIssuer` and writes it to a `Secret`. **Issuer-agnostic**: point it at any
issuer by name/kind (e.g. the Let's Encrypt ClusterIssuer from
`tf-dt-cert-manager-cloudflare-issuer`). The resulting Secret is consumed by a
Gateway/Ingress TLS listener.

The cert is app-coupled (hostnames + secret name) but kept in the Terraform/infra
layer so all the cert-manager wiring lives together rather than split into the app
chart.

## Usage

```hcl
module "match_certificate" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//generic/tf-hosted-modules/tf-dt-cert-manager-certificate?ref=<tag>"

  name        = "match-tls"
  namespace   = "match"
  dns_names   = ["match.example.com"]
  issuer_name = "letsencrypt-prod"   # e.g. module.cert_manager_issuer.cluster_issuer_name
  # secret_name defaults to var.name; issuer_kind defaults to ClusterIssuer

  depends_on = [module.cert_manager_issuer] # the issuer must exist first
}
```

Then point the TLS consumer at `module.match_certificate.secret_name` (e.g. the
`tf-dt-gke-gateway` `tls_secret_name`).

## Notes

- Uses `kubernetes_manifest` → needs the cluster + cert-manager CRDs reachable at
  plan time. Apply after the cert-manager operator and the issuer.
- `var.namespace` must already exist (the Certificate and its Secret are created
  there) - create the app namespace before this module.
- Optional `duration` / `renew_before` map to `spec.duration` /
  `spec.renewBefore`; omit to use the issuer defaults.

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | Name of the Certificate resource. | `string` | n/a |
| namespace | Namespace for the Certificate + its Secret. | `string` | n/a |
| dns_names | Hostnames the cert is issued for. | `list(string)` | n/a |
| issuer_name | Issuer name (issuerRef.name). | `string` | n/a |
| secret_name | Secret to write the cert into. | `string` | `null` (= name) |
| issuer_kind | ClusterIssuer or Issuer. | `string` | `"ClusterIssuer"` |
| issuer_group | issuerRef.group. | `string` | `null` |
| duration | spec.duration. | `string` | `null` |
| renew_before | spec.renewBefore. | `string` | `null` |
| labels | Extra labels. | `map(string)` | `{}` |
| annotations | Extra annotations. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| name | Name of the Certificate. |
| secret_name | Secret holding the issued cert/key. |
| namespace | Namespace of the Certificate + Secret. |
<!-- END_TF_DOCS -->
