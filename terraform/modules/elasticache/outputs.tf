output "primary_endpoint" {
  description = "Primary Redis endpoint address."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Read-only Redis endpoint address."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Port exposed by the Redis replication group."
  value       = var.port
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret storing the Redis auth token."
  value       = aws_secretsmanager_secret.redis.arn
}

output "security_group_id" {
  description = "Security group protecting Redis."
  value       = aws_security_group.this.id
}
