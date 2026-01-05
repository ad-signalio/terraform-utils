locals {
  cluster_name_prefix = var.env_name
}

resource "random_password" "db_password" {
  length      = 24
  special     = false
  min_lower   = 5
  min_upper   = 5
  min_numeric = 5
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0" # 7.0 dropped support for the password variable we use below, so pinning to 6.x for now

  identifier = var.env_name

  engine                = "postgres"
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  # match is a reserved database name for RDS Postgres
  db_name  = "matchdb"
  username = "matchdb"
  port     = "5432"


  db_subnet_group_name = var.env_name

  create_cloudwatch_log_group     = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true

  vpc_security_group_ids = var.vpc_security_group_ids

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  monitoring_interval                   = var.enhanced_monitoring_interval
  monitoring_role_name                  = "${var.env_name}-rds-monitor"
  create_monitoring_role                = var.enhanced_monitoring_interval > 0 ? true : false

  # It would require 2x terraform runs to turn of password rotation by setting manage_master_user_password_rotation to false as it
  # can't be disable on initial rotation. As we don't have a mechanism to co-ordinate automatic rotation with the app side,
  # setting the password manually here.
  manage_master_user_password          = false
  password                             = random_password.db_password.result
  manage_master_user_password_rotation = false

  multi_az = true

  tags = var.tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids

  # DB parameter group
  family = var.parameter_group_family

  parameter_group_name = "${var.env_name}-postgres"

  # Database Deletion Protection
  deletion_protection = var.deletion_protection

  parameters = concat([
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ], var.parameters)
}

// TODO: Delete this resource in future cleanup
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "${var.env_name}-rds-pg"
    namespace = var.k8s_namespace
  }

  data = {
    username = module.db.db_instance_username
    password = random_password.db_password.result
    host     = module.db.db_instance_address
    port     = module.db.db_instance_port
    db_name  = module.db.db_instance_name
  }

  type = "Opaque"
}

resource "aws_secretsmanager_secret" "rds_pg" {
  count       = var.create_aws_secret ? 1 : 0
  name_prefix = "${var.secret_naming_convention}-rds-pg"
  description = "Rds details for ${var.env_name}"

  recovery_window_in_days = 0

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "rds_pg_version" {
  count     = var.create_aws_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds_pg[0].id
  secret_string = jsonencode({
    username = module.db.db_instance_username
    password = random_password.db_password.result
    host     = module.db.db_instance_address
    port     = tostring(module.db.db_instance_port)
    db_name  = module.db.db_instance_name
  })
}
