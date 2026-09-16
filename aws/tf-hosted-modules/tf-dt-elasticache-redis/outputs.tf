output "redis" {
  value = module.elasticache_redis
}

output "primary_endpoint" {
  value = module.elasticache_redis.replication_group_primary_endpoint_address
}

output "reader_endpoint" {
  value = module.elasticache_redis.replication_group_reader_endpoint_address
}

output "redis_secret_name" {
  value = aws_secretsmanager_secret.redis_url[0].name
}

output "redis_url" {
  description = "Connection URL for the primary endpoint, for the match chart's sidekiq.redisServerUrl and redisClientUrl. Built the same way as the Secrets Manager value above, so the two cannot drift. rediss:// because transit encryption is on."
  value       = "rediss://${module.elasticache_redis.replication_group_primary_endpoint_address}:6379"
}
