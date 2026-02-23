provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = var.eks_cluster_certificate
  token                  = var.eks_cluster_token
}
