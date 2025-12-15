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