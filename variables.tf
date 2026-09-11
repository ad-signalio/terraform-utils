variable "env_name" {
  description = "The environment name (e.g., sbox-adsignal-shared-us1)"
  type        = string

  validation {
    # 64-char IAM role name cap minus the longest suffix iam.tf appends (-secrets-role, 13 chars).
    condition     = length(var.env_name) <= 51
    error_message = "env_name must be 51 characters or fewer: efs_csi_irsa/ebs_csi_irsa/secrets_csi_irsa build IAM role names from it (e.g. \"${var.env_name}-secrets-role\"), and AWS IAM role names cap at 64 characters."
  }
}

variable "node_count" {
  description = "Number of compute nodes for the EKS cluster"
  type        = number
  default     = 1
}

variable "node_instance_type" {
  description = "Instance type for EKS compute nodes"
  type        = string
  default     = "t3.2xlarge"
}

variable "access_entries" {
  description = "Map of extra Cluster access entries. See terraform-aws-modules/eks/aws for details."
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  default     = {}
  type        = map(string)
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "subnets_in_az" {
  description = "A list of subnet IDs in the specified availability zone"
  type        = list(string)
}

variable "secret_naming_convention" {
  description = "Naming convention for secrets to be accessed by the service account. This should correspond to the naming convention used in secrets manager."
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}

variable "ascp_addon_version" {
  description = "The version of the AWS Secrets Store CSI Driver Provider (ASCP) EKS add-on"
  type        = string
  default     = "v3.1.0-eksbuild.1"
}

variable "use_auto_mode" {
  description = "Choose to use, EKS Auto Mode. Default is true. If false, `node_count` and `node_instance_type` variables will be used to create a managed node group with specified count and instance type."
  type        = bool
  default     = true
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to grant admin permissions to the user who creates the cluster. Default is true."
  type        = bool
  default     = false
}
variable "create_compute_dependent_addons" {
  description = <<-DESC
    Create the addons that need compute before terraform will consider them
    healthy: metrics-server and aws-efs-csi-driver, both Deployments.

    Set false for the apply that creates the cluster when compute comes from
    custom node pools. Those are Kubernetes CRDs, so they cannot be planned
    until the cluster exists, which means they land in a later apply -- and
    these addons would otherwise sit DEGRADED with
    InsufficientNumberOfReplicas until the addon create timeout, failing that
    first apply. Leave at the default for every apply after it.

    Only consulted under use_auto_mode. With managed node groups the upstream
    module already orders addons after the node groups.
  DESC
  type        = bool
  default     = true
}

variable "use_builtin_node_pools" {
  description = <<-DESC
    Use EKS Auto Mode's built-in "system" and "general-purpose" node pools.

    Set false when supplying custom node pools -- notably to get tags onto compute,
    which the built-in pools cannot do: they use the default NodeClass, which
    carries no tags. See the tf-dt-eks-auto-mode-nodepool module.

    When false, this module creates the EC2 access entry the node IAM role needs,
    because EKS only manages node access automatically for the built-in pools.
  DESC
  type        = bool
  default     = false
}
