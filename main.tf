# EKS Auto Mode compute that can be tagged.
#
# The built-in "system" and "general-purpose" node pools use the default
# NodeClass, which cannot carry tags -- so the EC2 instances, EBS volumes and
# network interfaces they launch are untagged, and that is most of the bill.
# There is no launch template to reach either: eks_managed_node_groups is null
# under Auto Mode.
#
# These are like-for-like replacements. Both built-in pools use the default
# NodeClass, on-demand capacity, the C/M/R instance families and generation 5 or
# newer. "system" additionally carries the CriticalAddonsOnly taint and allows
# arm64; "general-purpose" is amd64 only.
#
# Requires the cluster to be created with compute_config.node_pools = null, and
# an EC2 access entry for the node IAM role -- the EKS module does not create one,
# because EKS handles node access internally for the built-in pools only.

locals {
  base_requirements = [
    {
      key      = "eks.amazonaws.com/instance-category"
      operator = "In"
      values   = var.instance_categories
    },
    {
      key      = "eks.amazonaws.com/instance-generation"
      operator = "Gt"
      values   = [var.min_instance_generation]
    },
    {
      key      = "karpenter.sh/capacity-type"
      operator = "In"
      values   = var.capacity_types
    },
  ]

  disruption = {
    consolidationPolicy = var.consolidation_policy
    consolidateAfter    = var.consolidate_after
  }
}

resource "kubernetes_manifest" "node_class" {
  count = var.enabled ? 1 : 0

  manifest = {
    apiVersion = "eks.amazonaws.com/v1"
    kind       = "NodeClass"
    metadata = {
      name = var.name
    }
    spec = {
      role                       = var.node_iam_role_name
      subnetSelectorTerms        = [for id in var.subnet_ids : { id = id }]
      securityGroupSelectorTerms = [for id in var.security_group_ids : { id = id }]

      # The reason this module exists.
      tags = var.tags
    }
  }
}

resource "kubernetes_manifest" "system" {
  count = var.enabled && var.create_system_node_pool ? 1 : 0

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "system"
    }
    spec = {
      template = {
        spec = {
          nodeClassRef = {
            group = "eks.amazonaws.com"
            kind  = "NodeClass"
            name  = var.name
          }
          requirements = concat(local.base_requirements, [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64", "arm64"]
            },
          ])
          # Matches the built-in system pool. Add-ons such as CoreDNS tolerate
          # this; without it they would schedule anywhere and the pool would not
          # be reserved for cluster-critical workloads.
          taints = [
            {
              key    = "CriticalAddonsOnly"
              effect = "NoSchedule"
            },
          ]
        }
      }
      disruption = local.disruption
    }
  }

  depends_on = [kubernetes_manifest.node_class]
}

resource "kubernetes_manifest" "general_purpose" {
  count = var.enabled && var.create_general_purpose_node_pool ? 1 : 0

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "general-purpose"
    }
    spec = {
      template = {
        spec = {
          nodeClassRef = {
            group = "eks.amazonaws.com"
            kind  = "NodeClass"
            name  = var.name
          }
          requirements = concat(local.base_requirements, [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
          ])
        }
      }
      disruption = local.disruption
    }
  }

  depends_on = [kubernetes_manifest.node_class]
}
