# tf-dt-eks-auto-mode-nodepool

Tagged compute for EKS Auto Mode.

## Why

Auto Mode's built-in `system` and `general-purpose` node pools use the **default
NodeClass, which cannot carry tags**. The EC2 instances, EBS volumes and network
interfaces they launch are therefore untagged — and that is most of an EKS bill.
There is no launch template to reach either: `eks_managed_node_groups` is `null`
under Auto Mode, so `launch_template_tags` never applies.

This module creates a NodeClass that *does* carry tags, plus like-for-like
replacements for both built-in pools.

## Like-for-like

Both built-in pools use the default NodeClass, on-demand capacity, the C/M/R
instance families and generation 5 or newer. The differences:

| Pool | Architectures | Taint |
|---|---|---|
| `system` | `amd64`, `arm64` | `CriticalAddonsOnly:NoSchedule` |
| `general-purpose` | `amd64` | none |

The taint matters. Cluster-critical add-ons such as CoreDNS tolerate it; omit it
and the pool is no longer reserved for them.

## Required cluster configuration

Two things, neither of which the EKS module does for you:

1. **`compute_config.node_pools = null`** on the cluster. Note `[]` is not
   equivalent — the EKS module reads `node_pools != null` to decide whether to set
   `node_role_arn`, so an empty list still sets it. `null` gives the state AWS
   documents for a cluster without built-in pools.
2. **An `EC2` access entry for the node IAM role.** The EKS module builds access
   entries only from the cluster-creator bootstrap entry and `var.access_entries`;
   it never adds one for the Auto Mode node role, because EKS handles node access
   internally for the built-in pools. Without the entry, nodes cannot join.

## Ordering

These are CRDs, so `kubernetes_manifest` needs the cluster's API reachable at
plan time. Expect the usual two-stage apply: the cluster first, then this.

Between the two stages the cluster has no compute, so add-ons will sit pending
until the NodePools exist. That is expected, not a failure.

## Usage

```hcl
module "auto_mode_nodepool" {
  source = "git::https://github.com/ad-signalio/terraform-utils.git?ref=aws/tf-hosted-modules/tf-dt-eks-auto-mode-nodepool/v0.0.1"

  node_iam_role_name = module.eks.node_iam_role_name
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.eks.eks_cluster_node_sg]
  tags               = module.label.tags
}
```

Set `enabled = false` to fall back to the built-in pools, accepting untagged
compute.
