# tf-dt-nfs-provisioner

Terraform module to deploy an in-cluster NFS server + dynamic RWX provisioner
via the kubernetes-sigs [nfs-ganesha-server-and-external-provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner)
Helm chart. Provides a `ReadWriteMany` StorageClass backed by a single RWO
cloud disk — the cloud-agnostic shared-storage layer for match internal test
environments (and a bare-metal option), replacing EFS/Filestore where a
managed NFS service is not justified.

```
RWO disk (EBS / GCP PD / local-path)
  → NFS server pod (Ganesha, userspace — no kernel module, no privileged mode)
    → RWX StorageClass → shared PVC mounted by web / workers / scaled jobs
```

Validated end-to-end (cross-node RWX, UID/GID 65532 read/write, `fcntl`/`flock`
locking incl. long-held locks across server restarts, atomic rename, zero data
loss). Chosen over the OpenEBS dynamic-nfs-provisioner, which is archived
upstream.

## Non-obvious configuration this module encodes

| Setting | Why |
|---|---|
| `mountOptions: vers=4.1` | Chart default is NFSv3. v4.1 has protocol-native locking — required for the `.lo` lock files in the audio pipeline. |
| `mountOptions: addr=<clusterIP>` + pinned `service.clusterIP` | Minimal host OSes (Bottlerocket / EKS Auto Mode) ship no `mount.nfs` helper; the in-tree NFS mount fails with "mount program didn't pass remote address" unless the address is passed explicitly. Pinning the Service IP makes this declarative. |
| `parameters.gid` | Provisioned exports become setgid group dirs owned by this GID, so nonroot pods (match runs as 65532) can read/write. |

## Availability profile

Single NFS server pod: a reschedule pauses I/O briefly; hard mounts (default)
recover transparently and NFSv4.1 grace-period reclaim preserves held locks.
Suitable for internal testing — production client deployments should use a
managed NFS service (EFS / Filestore).

## Usage

```hcl
module "nfs_provisioner" {
  source = "git::https://github.com/ad-signalio/terraform-utils.git?ref=generic/tf-hosted-modules/tf-dt-nfs-provisioner/v1.0.0"

  # Free IP inside the cluster's Service CIDR (EKS default 172.20.0.0/16)
  service_cluster_ip    = "172.20.200.10"
  backing_storage_class = "auto-ebs-gp2" # GKE: standard-rwo; bare metal: local-path
  backing_disk_size     = "200Gi"
}

# helm-match values: storage.sharedStorage.storageClassName = module.nfs_provisioner.storage_class_name
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.nfs_provisioner](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backing_disk_size"></a> [backing\_disk\_size](#input\_backing\_disk\_size) | Size of the backing disk for the NFS server. | `string` | `"200Gi"` | no |
| <a name="input_backing_storage_class"></a> [backing\_storage\_class](#input\_backing\_storage\_class) | RWO StorageClass backing the NFS server's disk (e.g. auto-ebs-gp2 on EKS Auto Mode, standard-rwo on GKE). null uses the cluster default. | `string` | `null` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the kubernetes-sigs nfs-server-provisioner Helm chart. | `string` | `"1.8.0"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether to deploy the NFS provisioner. | `bool` | `true` | no |
| <a name="input_export_gid"></a> [export\_gid](#input\_export\_gid) | GID applied to provisioned exports (setgid group dir). Pods running with this group can read/write. Match pods run as 65532 (nonroot). | `number` | `65532` | no |
| <a name="input_extra_mount_options"></a> [extra\_mount\_options](#input\_extra\_mount\_options) | Additional NFS mount options appended after vers=4.1 and addr=. | `list(string)` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to install the NFS provisioner into (created if absent). | `string` | `"nfs-provisioner"` | no |
| <a name="input_reclaim_policy"></a> [reclaim\_policy](#input\_reclaim\_policy) | ReclaimPolicy for the consumer StorageClass (Delete or Retain). | `string` | `"Delete"` | no |
| <a name="input_release_name"></a> [release\_name](#input\_release\_name) | Helm release name. | `string` | `"nfs-provisioner"` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Resource requests/limits for the NFS server pod. | `any` | <pre>{<br/>  "limits": {<br/>    "memory": "512Mi"<br/>  },<br/>  "requests": {<br/>    "cpu": "100m",<br/>    "memory": "256Mi"<br/>  }<br/>}</pre> | no |
| <a name="input_service_cluster_ip"></a> [service\_cluster\_ip](#input\_service\_cluster\_ip) | ClusterIP to pin the NFS server Service to. Must be a free IP inside the<br/>cluster's Service CIDR. Required because the StorageClass mountOptions<br/>reference it via addr= — needed on minimal host OSes (e.g. Bottlerocket)<br/>that ship no mount.nfs userspace helper. | `string` | n/a | yes |
| <a name="input_settings"></a> [settings](#input\_settings) | Additional settings to pass to the Helm chart (merged last, overrides module defaults). | `map(any)` | `{}` | no |
| <a name="input_storage_class_name"></a> [storage\_class\_name](#input\_storage\_class\_name) | Name of the RWX StorageClass the provisioner creates for consumers. | `string` | `"match-shared-storage-nfs"` | no |
| <a name="input_values"></a> [values](#input\_values) | List of values in raw YAML format to pass to the helm release. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the NFS provisioner is installed into. |
| <a name="output_service_cluster_ip"></a> [service\_cluster\_ip](#output\_service\_cluster\_ip) | Pinned ClusterIP of the NFS server Service. |
| <a name="output_storage_class_name"></a> [storage\_class\_name](#output\_storage\_class\_name) | Name of the RWX StorageClass created for consumers (use as storage.sharedStorage.storageClassName in helm-match values). |
<!-- END_TF_DOCS -->
