module "github" {
  source       = "git::https://github.com/ad-signalio/terraform-utils-private.git//generic/tf-hosted-modules/tf-dt-github?ref=v1.0.17"
  github_token = var.github_token

  eks_cluster_endpoint = var.eks_cluster.cluster_endpoint
  eks_cluster_name     = var.eks_cluster.cluster_name

  domain_name = var.domain_name

  vpc_id = var.vpc

  secret_store_role_arn = var.secret_store_role_arn
  rds_pg_secret_name    = var.rds_pg_secret_name
  environment_size      = var.environment_size
  smtp_secret_name      = var.smtp_secret_name
  organisation_name     = var.organisation_name
  api_secret_name       = var.api_secret_name
  user_secret_name      = var.user_secret_name
  owning_user_email     = var.owning_user_email
}


output "github_pr" {
  value = module.github.github_pr
}
