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
| [kubernetes_manifest.certificate](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Extra annotations on the Certificate. | `map(string)` | `{}` | no |
| <a name="input_dns_names"></a> [dns\_names](#input\_dns\_names) | Hostnames the certificate is issued for (spec.dnsNames). At least one. | `list(string)` | n/a | yes |
| <a name="input_duration"></a> [duration](#input\_duration) | Optional requested certificate validity (spec.duration), e.g. "2160h" (90d). Null = issuer default. | `string` | `null` | no |
| <a name="input_issuer_group"></a> [issuer\_group](#input\_issuer\_group) | Issuer group (spec.issuerRef.group). Defaults to cert-manager.io when omitted. | `string` | `null` | no |
| <a name="input_issuer_kind"></a> [issuer\_kind](#input\_issuer\_kind) | Issuer kind (spec.issuerRef.kind): ClusterIssuer or Issuer. | `string` | `"ClusterIssuer"` | no |
| <a name="input_issuer_name"></a> [issuer\_name](#input\_issuer\_name) | Name of the issuer to request the cert from (spec.issuerRef.name). | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Extra labels on the Certificate. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Certificate resource. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the Certificate and the TLS Secret it produces. Must exist (e.g. the app's namespace). | `string` | n/a | yes |
| <a name="input_renew_before"></a> [renew\_before](#input\_renew\_before) | Optional how long before expiry to renew (spec.renewBefore), e.g. "360h" (15d). Null = issuer default. | `string` | `null` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name of the Secret cert-manager writes the cert/key into. Defaults to var.name. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_name"></a> [name](#output\_name) | Name of the Certificate resource. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace of the Certificate and its Secret. |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Name of the Secret cert-manager writes the cert/key into. Reference this from the TLS consumer (Gateway listener, Ingress, etc.). |
<!-- END_TF_DOCS -->
