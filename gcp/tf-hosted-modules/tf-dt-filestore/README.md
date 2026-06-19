# tf-dt-filestore

Managed **GCP Filestore** for production-tier RWX shared storage - the SLA-backed
alternative to the in-cluster `tf-dt-nfs-provisioner` (which is single-pod and
only suitable for internal/test/bare-metal tiers). The match pipeline needs a
`ReadWriteMany` volume across web / worker / scaled-job pods; this provides it
from a managed NFS filesystem.

Creates a Filestore instance plus a **static** `PersistentVolume` + `PersistentVolumeClaim`
bound to its export via the GKE **Filestore CSI driver**, so the helm-match chart
consumes it through `storage.sharedStorage.claimName` (default
`match-shared-storage`).

> ⚠️ **Cost:** `BASIC_HDD` has a **1 TiB minimum (~$200/month)**. Only stand this
> up for real production demand - internal/test/bare-metal use the NFS provisioner.

## Usage

```hcl
module "filestore" {
  source = "git::https://github.com/ad-signalio/terraform-utils-private.git?ref=gcp/tf-hosted-modules/tf-dt-filestore/<tag>"

  project_id = var.gcp_project_id
  name       = "${var.env_id}-fs"
  location   = var.zone               # BASIC tiers are zonal
  network    = module.vpc.network_name
  # capacity_gb = 1024  (1 TiB, the BASIC_HDD minimum/default)

  # PVC the chart binds to (defaults: name match-shared-storage, ns match)
  namespace = "match"

  depends_on = [module.gke]
}
```

Then in the env values, select Filestore instead of the NFS provisioner:
`storage.sharedStorage.claimName: "match-shared-storage"` (the chart default) and
**don't** deploy `tf-dt-nfs-provisioner`.

## Prerequisites

- **Filestore CSI driver** enabled on the GKE cluster
  (`filestore.csi.storage.gke.io`). On GKE this is the
  `gcpFilestoreCsiDriverConfig` addon - enable it on the cluster (a `tf-dt-gke`
  flag, or `gcloud container clusters update <c> --update-addons=GcpFilestoreCsiDriver=ENABLED`).
- The instance's `network` must be the cluster's VPC. `DIRECT_PEERING` (default)
  lets Filestore manage its own peering; use `PRIVATE_SERVICE_ACCESS` +
  `reserved_ip_range` to reuse the VPC's PSA range.

## Nonroot permissions (UID/GID 65532)

The match pods run as nonroot (65532). Filestore has **no per-export gid setting**
(unlike the NFS provisioner's `export_gid`), so grant write access at the pod
level with **`podSecurityContext.fsGroup: 65532`** - the CSI driver applies the
fsGroup to the mount. (This mirrors the EFS access-point / NFS-provisioner gid
requirement from sc-22514.)

## Validation (deferred - run when first stood up)

Per the ticket this is deferred until customer demand. When stood up, validate as
in sc-22514:
1. `kubectl get pvc match-shared-storage -n match` → `Bound`.
2. From a web pod and a worker/scaled-job pod, write to the RWX mount
   (`/app/storage`) and read it back from the other → confirms RWX.
3. Confirm the writes are owned by `65532` and a nonroot pod can read/write.

## Notes

- `deletion_protection_enabled` defaults `true` - disable for throwaway instances.
- Tier options: `BASIC_HDD` (cheapest), `BASIC_SSD`, `ZONAL`, `REGIONAL`,
  `ENTERPRISE`. Only `BASIC_*`/`ZONAL` are zonal (set `location` to a zone).

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_id | GCP project ID. | `string` | n/a |
| name | Filestore instance name. | `string` | n/a |
| location | Zone (BASIC tiers are zonal). | `string` | n/a |
| network | Authorized VPC network name/self-link. | `string` | n/a |
| tier | Service tier. | `string` | `"BASIC_HDD"` |
| capacity_gb | Share capacity (GiB, min 1024). | `number` | `1024` |
| share_name | NFS share/export name. | `string` | `"share1"` |
| connect_mode | DIRECT_PEERING or PRIVATE_SERVICE_ACCESS. | `string` | `"DIRECT_PEERING"` |
| reserved_ip_range | /29 CIDR or PSA range name. | `string` | `null` |
| labels | Instance labels. | `map(string)` | `{}` |
| deletion_protection_enabled | Protect from deletion. | `bool` | `true` |
| create_kubernetes_resources | Create the static PV + PVC. | `bool` | `true` |
| pvc_name | RWX PVC name. | `string` | `"match-shared-storage"` |
| namespace | PVC namespace. | `string` | `"match"` |
| pv_name | Static PV name. | `string` | `null` (= `<name>-pv`) |
| storage_class_name | storageClassName for the static PV/PVC. | `string` | `""` |

## Outputs

| Name | Description |
|------|-------------|
| instance_name | Filestore instance name. |
| ip_address | NFS share IP. |
| share_name | Export name. |
| pv_name | Static PV name (or null). |
| pvc_name | RWX PVC name (or null). |
<!-- END_TF_DOCS -->
