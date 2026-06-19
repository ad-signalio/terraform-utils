# tf-dt-gke-gateway

A GKE **Gateway API** `Gateway` plus its reserved global external IP — the
cloud-specific routing front door that app `HTTPRoute`s attach to. Pairs with
the helm chart's `HTTPRoute` (cloud-agnostic) and, for TLS, with a cert-manager
`Certificate` that populates the listener's secret.

- Always creates an **HTTP:80** listener.
- When `enable_tls = true`, also creates an **HTTPS:443** listener that
  terminates TLS from `tls_secret_name`, and reserves + binds a **global static
  IP** (so DNS has a stable target for the cert).
- Uses GatewayClass `gke-l7-global-external-managed` by default (global external
  L7 load balancer).

The TLS **certificate is not created here**. `tls_secret_name` (default
`match-tls`) is expected to be populated externally — e.g. the app chart ships a cert-manager `Certificate` whose `secretName` matches. This keeps the
cloud-infra Gateway decoupled from the app-coupled cert.

## Usage

```hcl
module "gke_gateway" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-gke-gateway?ref=<tag>"

  project_id = var.gcp_project_id
  namespace  = "match"            # same ns as the app + its HTTPRoute

  # TLS (optional). Omit for HTTP-only validation (auto-allocated IP).
  enable_tls = true
  hostname   = "match.example.com"
  # tls_secret_name defaults to "match-tls" - match the app chart's Certificate.

  depends_on = [module.gke] # Gateway API CRDs + the namespace must exist first
}
```

Point DNS at `module.gke_gateway.static_ip_address`, and set the app chart's
`httpRoute.parentRefs[].name` to `module.gke_gateway.gateway_name`.

## Requirements

- The cluster must have the **Gateway API channel** enabled (e.g. `tf-dt-gke`
  `gateway_api_channel = "CHANNEL_STANDARD"`), which installs the Gateway API
  CRDs and the GKE managed GatewayClasses.
- A `kubernetes` provider configured against the cluster, and a `google`
  provider for the address.

## Notes / gotchas

- This uses `kubernetes_manifest`, which needs the cluster **reachable and the
  Gateway API CRDs present at plan time**. Apply in stages on a fresh cluster:
  create the cluster (CRDs) first, then this module.
- On teardown, `kubernetes_manifest` can fail to plan once the cluster is gone
  (`cannot create REST client`). `terraform state rm` the Gateway and/or scope
  the destroy to the surviving resources. The GKE Gateway controller may also
  leave orphaned NEGs (`k8s1-…`) that block VPC deletion - delete them with
  `gcloud compute network-endpoint-groups delete`.
- To use cert-manager's **gateway-shim** auto-issuance instead of an explicit
  `Certificate`, pass `annotations = { "cert-manager.io/cluster-issuer" = "…" }`
  (requires the `ExperimentalGatewayAPISupport` feature gate on cert-manager).

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_id | GCP project ID (for the reserved global address). | `string` | n/a |
| namespace | Namespace the Gateway is created in. | `string` | n/a |
| gateway_name | Name of the Gateway resource. | `string` | `"match-gateway"` |
| gateway_class_name | GatewayClass. | `string` | `"gke-l7-global-external-managed"` |
| enable_tls | Add an HTTPS:443 listener + bind a reserved static IP. | `bool` | `false` |
| hostname | Hostname for the HTTPS listener (required when enable_tls). | `string` | `""` |
| tls_secret_name | Secret holding the TLS cert/key for the HTTPS listener. | `string` | `"match-tls"` |
| create_static_ip | Reserve + bind a global IP. Defaults to enable_tls. | `bool` | `null` |
| static_ip_name | Name for the reserved global address. | `string` | `null` |
| annotations | Extra annotations on the Gateway. | `map(string)` | `{}` |
| allowed_routes_from | allowedRoutes.namespaces.from for the listeners. | `string` | `"Same"` |

## Outputs

| Name | Description |
|------|-------------|
| gateway_name | Name of the Gateway (HTTPRoute parentRefs[].name). |
| namespace | Namespace the Gateway is in. |
| static_ip_address | The reserved global external IP, or null. |
| static_ip_name | Name of the reserved global address, or null. |
<!-- END_TF_DOCS -->
