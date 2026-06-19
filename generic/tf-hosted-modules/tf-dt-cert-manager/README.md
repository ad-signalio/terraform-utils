# tf-dt-cert-manager

Installs [cert-manager](https://cert-manager.io) (controller + CRDs) via Helm -
the same helm-only pattern as `tf-dt-external-secrets` and `tf-dt-keda`. Part of
the cloud-agnostic TLS story: cert-manager replaces ACM / GKE
ManagedCertificate and works identically on GCP, AWS, and on-prem.

## What it installs

- The cert-manager **controller, webhook, cainjector, and CRDs** (`crds.enabled = true`).
- The Gateway API **feature gate** (`ExperimentalGatewayAPISupport=true`) so the
  cert-manager *gateway-shim* can auto-issue and renew certificates for Gateways
  annotated with `cert-manager.io/cluster-issuer` (no explicit `Certificate`
  resource needed).

## What it does NOT install (environment-owned)

- **`ClusterIssuer` / `Issuer`** and the ACME/DNS-01 solver config.
- The **DNS-provider API token** Secret (e.g. a Cloudflare `Zone:DNS:Edit` token).

These are per-environment (the token is a secret; the issuer references env DNS),
so they live in the consuming environment - mirroring how `tf-dt-external-secrets`
installs ESO but leaves SecretStore/ExternalSecret to the env's chart.

## Usage

```hcl
module "cert_manager" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//generic/tf-hosted-modules/tf-dt-cert-manager?ref=<tag-or-branch>"

  chart_version = "v1.16.2"
  # namespace defaults to "cert-manager"

  depends_on = [module.gke] # CRDs need a cluster
}
```

Then create a `ClusterIssuer` (Let's Encrypt + Cloudflare DNS-01) and the token
Secret in the environment, and annotate the Gateway with
`cert-manager.io/cluster-issuer: <issuer-name>`.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `enabled` | Install cert-manager. | `true` |
| `chart_version` | jetstack/cert-manager chart version (>= v1.15 for `crds.enabled` + Gateway feature gate). | `"v1.16.2"` |
| `namespace` | Namespace to install into (created if absent). | `"cert-manager"` |
| `settings` | Map merged into Helm values. | `{}` |
| `values` | Raw YAML value documents. | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| `namespace` | Namespace cert-manager is installed into. |
