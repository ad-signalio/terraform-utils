variable "enabled" {
  description = "Create the NodeClass and NodePools. Set false to rely on the EKS Auto Mode built-in node pools instead, which cannot be tagged."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the NodeClass. The NodePools reference it. Must not be \"default\" -- EKS Auto Mode provisions its own NodeClass under that name whenever a built-in NodePool is enabled."
  type        = string
  default     = "tagged"
}

variable "node_iam_role_name" {
  description = "Name (not ARN) of the EKS Auto Mode node IAM role. From the EKS module's node_iam_role_name output."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets nodes are launched into. Usually the cluster's private subnets."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to nodes. Usually the cluster node security group."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to the EC2 instances, volumes and network interfaces the NodePools launch. This is the only way to tag EKS Auto Mode compute -- the built-in node pools use the default NodeClass, which cannot carry tags."
  type        = map(string)
  default     = {}
}

variable "instance_categories" {
  description = "EC2 instance categories nodes may use. Matches the built-in pools by default."
  type        = list(string)
  default     = ["c", "m", "r"]
}

variable "min_instance_generation" {
  description = "Minimum EC2 instance generation, exclusive. The built-in pools require generation 5 or newer, so 4."
  type        = string
  default     = "4"
}

variable "capacity_types" {
  description = "Capacity types nodes may use. The built-in pools are on-demand only."
  type        = list(string)
  default     = ["on-demand"]
}

variable "create_system_node_pool" {
  description = "Create a replacement for the built-in 'system' pool: the same shape, plus the CriticalAddonsOnly taint that cluster-critical add-ons such as CoreDNS tolerate."
  type        = bool
  default     = true
}

variable "create_general_purpose_node_pool" {
  description = "Create a replacement for the built-in 'general-purpose' pool."
  type        = bool
  default     = true
}

variable "consolidation_policy" {
  description = "Karpenter consolidation policy for both pools."
  type        = string
  default     = "WhenEmptyOrUnderutilized"
}

variable "consolidate_after" {
  description = "How long a node must be a consolidation candidate before it is acted on."
  type        = string
  default     = "30s"
}
