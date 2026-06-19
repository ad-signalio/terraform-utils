# tf-dt-gke-gateway-tls

The GKE **Gateway API** front door **plus** its cert-manager TLS (ClusterIssuer +
Certificate + Cloudflare DNS-01 token), shipped as a **single `helm_release`** so
the whole stack applies in **one `terraform apply` alongside the cluster** - no
staged/tiered apply.

This is the single-apply alternative to composing the granular
`tf-dt-gke-gateway` + `tf-dt-cert-manager-cloudflare-issuer` +
`tf-dt-cert-manager-certificate` modules (which use `kubernetes_manifest` and
therefore require the cluster + CRDs to exist at plan time).

## Why it avoids tiering

- `kubernetes_manifest` fetches the resource's schema from the **live cluster at
  plan time**, so it can't be created in the same apply as the cluster.
- `helm_release` **templates the chart locally at plan time** and only contacts
  the API at apply - after the cluster and cert-manager exist (ordered by
  `depends_on`). So a single apply works.
- Pair with **exec auth** on the kubernetes/helm providers (lazy auth) so they can
  configure against the not-yet-created cluster:
  ```hcl
  provider "helm" {
    kubernetes = {
      host                   = "https://${module.gke.cluster_endpoint}"
      cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
      exec = { api_version = "client.authentication.k8s.io/v1beta1", command = "gke-gcloud-auth-plugin" }
    }
  }
  ```
  (Needs `gke-gcloud-auth-plugin` on PATH.)

## Usage

```hcl
module "gateway_tls" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git//gcp/tf-hosted-modules/tf-dt-gke-gateway-tls?ref=<tag>"

  project_id           = var.gcp_project_id
  namespace            = "match"
  enable_tls           = true
  hostname             = "match.example.com"
  acme_email           = "infra@example.com"
  cloudflare_api_token = var.cloudflare_api_token   # Zone:DNS:Edit + Zone:Read

  depends_on = [module.gke, module.cert_manager]    # cluster + cert-manager CRDs first
}
```

Point DNS at `module.gateway_tls.static_ip_address`; set the app chart's
`httpRoute.parentRefs[].name` to `module.gateway_tls.gateway_name`.

## What it creates

- `google_compute_global_address` - reserved global IP (when `enable_tls`/`create_static_ip`).
- A `helm_release` of the bundled chart:
  - **Gateway** (HTTP:80 always; HTTPS:443 + static-IP binding when `enable_tls`).
  - When `enable_tls`: **ClusterIssuer** (ACME, Cloudflare DNS-01), **Certificate**
    (→ `tls_secret_name`), and the **Cloudflare token Secret** (in
    `cert_manager_namespace`).
- `create_namespace = true` makes the release create `var.namespace` (e.g. `match`).

## Notes

- Requires the cluster's Gateway API channel (`tf-dt-gke` `gateway_api_channel = "CHANNEL_STANDARD"`) and the cert-manager operator (`tf-dt-cert-manager`) - pass both via `depends_on`.
- The Cloudflare token is passed through the helm release values and lands in TF state. For production, sync it via ESO and template the issuer to reference that Secret instead.
- Default `acme_server` is Let's Encrypt production; use the staging URL while iterating.
