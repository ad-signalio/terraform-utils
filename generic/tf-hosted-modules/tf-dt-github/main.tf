data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_pet" "branch_suffix" {
  length    = 2
  separator = "-"
}

data "github_repository_file" "env_yaml" {
  repository = "helm-match"
  branch     = "main"
  file       = "environment-sizes/${var.environment_size}/${var.environment_size}.yaml"
}

locals {
  repo_name     = "argocd-match-managed"
  source_branch = "staging"
  target_branch = "${var.eks_cluster_name}-automation-${random_pet.branch_suffix.id}"
  env_yaml_obj  = yamldecode(data.github_repository_file.env_yaml.content)

  certificate_arn = "arn:aws:acm:us-east-1:203960437845:certificate/573410f1-9a0d-4911-8ca2-6e4b36ed5912"

  cluster_config_json = templatefile("${path.module}/templates/cluster-config.json.tmpl", {
    name                  = var.eks_cluster_name
    server                = var.eks_cluster_endpoint
    eks_name              = var.eks_cluster_name
    account_id            = data.aws_caller_identity.current.account_id
    vpc_id                = var.vpc_id
    region                = data.aws_region.current.region
    secret_store_role_arn = var.secret_store_role_arn
    rds_pg_secret_name    = var.rds_pg_secret_name
    smtp_secret_name      = var.smtp_secret_name
    organisation_name     = var.organisation_name
    api_secret_name       = var.api_secret_name
    user_secret_name      = var.user_secret_name
    owning_user_email     = var.owning_user_email
  })

  values_yaml = "${templatefile("${path.module}/templates/match-values.yaml.tmpl", {
    eks_cluster_name  = var.eks_cluster_name
    domain            = var.domain_name
    certificate_arn   = local.certificate_arn
    account_id        = data.aws_caller_identity.current.account_id
    region            = data.aws_region.current.region
    organisation_name = var.organisation_name
    owning_user_email = var.owning_user_email
    api_secret_name   = var.api_secret_name
    user_secret_name  = var.user_secret_name
  })}\n${data.github_repository_file.env_yaml.content}"
}

resource "github_repository_file" "cluster_config" {
  repository                      = local.repo_name
  branch                          = local.target_branch
  autocreate_branch               = true
  autocreate_branch_source_branch = local.source_branch
  file                            = "cluster-resources-configurations/cluster-list/non-prod/${var.eks_cluster_name}.json"
  content                         = local.cluster_config_json
  commit_message                  = "Managed by Terraform"
  commit_author                   = "Terraform"
  commit_email                    = "terraform@ad-signal.io"
  overwrite_on_create             = true
}

resource "github_repository_file" "values_yaml" {
  repository                      = local.repo_name
  branch                          = local.target_branch
  autocreate_branch               = true
  autocreate_branch_source_branch = local.source_branch
  file                            = "application/environments/non-prod/${var.eks_cluster_name}.yaml"
  content                         = local.values_yaml
  commit_message                  = "Managed by Terraform"
  commit_author                   = "Terraform"
  commit_email                    = "terraform@ad-signal.io"
  overwrite_on_create             = true
  depends_on                      = [github_repository_file.cluster_config]

}

resource "github_repository_pull_request" "this" {
  base_repository = local.repo_name
  base_ref        = local.source_branch
  head_ref        = local.target_branch
  title           = "${var.eks_cluster_name} Cluster Config and Helm Values"
  body            = "Automation did this."

  depends_on = [github_repository_file.cluster_config, github_repository_file.values_yaml]
}
