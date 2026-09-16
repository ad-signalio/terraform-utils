data "aws_caller_identity" "current" {}

locals {
  name = var.env_name
}

module "elasticache_redis" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id               = local.name
  create_cluster           = false
  create_replication_group = true

  replication_group_id = local.name

  engine_version = "7.1"
  node_type      = "cache.t4g.small"

  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true

  # Security group
  vpc_id = var.vpc
  security_group_rules = {
    ingress_vpc = {
      # Default type is `ingress`
      # Default port is based on the default engine port
      description = "VPC traffic"
      cidr_ipv4   = var.cidr_block
    }
  }

  # Subnet Group
  subnet_ids               = var.private_subnets
  subnet_group_name        = local.name
  subnet_group_description = "${local.name} subnet group"

  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = var.tags

}

resource "aws_secretsmanager_secret" "redis_url" {
  count       = var.create_aws_secret ? 1 : 0
  name_prefix = "${var.secret_naming_convention}-redis-url"
  description = "Redis details for ${var.env_name}"

  recovery_window_in_days = 0

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "redis_url_version" {
  count     = var.create_aws_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.redis_url[0].id
  secret_string = jsonencode({
    endpoint        = "${module.elasticache_redis.replication_group_primary_endpoint_address}"
    url             = "redis://${module.elasticache_redis.replication_group_primary_endpoint_address}/6379/0"
    elasticache_url = "rediss://${module.elasticache_redis.replication_group_primary_endpoint_address}:6379"
  })
}

