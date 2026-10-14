output "rds_pg_secret_name" {
  value = aws_secretsmanager_secret.rds_pg[0].name
}

# The chart needs these three as literals, alongside the synced secret: the
# secret carries host, password and db_name, but postgres.database, .username
# and .port are plain values in values.yaml. Without outputs every environment
# retypes them and can get them wrong.

output "db_name" {
  description = "Database name, for the chart's postgres.database."
  value       = module.db.db_instance_name
}

output "db_username" {
  description = "Master username, for the chart's postgres.username."
  value       = module.db.db_instance_username
}

output "db_port" {
  description = "Port, for the chart's postgres.port."
  value       = module.db.db_instance_port
}

output "db_host" {
  description = "Instance address, without the port. For the chart's kedaAutoScaling.postgres.host: KEDA needs the host as a literal at render time and cannot read it from the synced secret."
  value       = module.db.db_instance_address
}
