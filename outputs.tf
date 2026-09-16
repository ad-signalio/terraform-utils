output "rds_pg_secret_name" {
  value = aws_secretsmanager_secret.rds_pg[0].name
}

# The chart needs these three as literals, alongside the synced secret: the
# secret carries host, password and db_name, but postgres.database, .username
# and .port are plain values in values.yaml. They are fixed in this module
# ("match" is a reserved database name for RDS Postgres, hence matchdb), so
# without outputs every environment retypes them and can get them wrong.
# Read back from the db module rather than the literals above, so they stay
# correct if these ever become variables.

output "db_name" {
  description = "Database name, for the match chart's postgres.database."
  value       = module.db.db_instance_name
}

output "db_username" {
  description = "Master username, for the match chart's postgres.username."
  value       = module.db.db_instance_username
}

output "db_port" {
  description = "Port, for the match chart's postgres.port."
  value       = module.db.db_instance_port
}
