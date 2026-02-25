output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks_al2023_cluster.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks_al2023_cluster.cluster_endpoint
}

output "eks_cluster_certificate" {
  description = "The certificate of the EKS cluster"
  value       = base64decode(module.eks_al2023_cluster.cluster_certificate_authority_data)
}

output "eks_cluster" {
  value = module.eks_al2023_cluster
}

output "eks_cluster_auth" {
  value     = data.aws_eks_cluster_auth.this
  sensitive = true
}

output "eks_cluster_token" {
  description = "The token to authenticate to the EKS cluster"
  value       = data.aws_eks_cluster_auth.this.token
}

output "eks_cluster_node_sg" {
  description = "The security group ID for the EKS cluster nodes"
  value       = module.eks_al2023_cluster.node_security_group_id
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks_al2023_cluster.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks_al2023_cluster.cluster_security_group_id
}

output "eks_oidc_arn" {
  description = "The ARN of the OIDC Provider"
  value       = local.oidc_provider_arn
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_al2023_cluster.cluster_name
}

output "secrets_csi_irsa_role_arn" {
  description = "The ARN of the IAM Role for the Secrets CSI Driver"
  value       = module.secrets_csi_irsa.arn
}