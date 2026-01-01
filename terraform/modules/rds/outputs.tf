output "endpoint" {
  description = "DNS address of the PostgreSQL instance."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Port exposed by the PostgreSQL instance."
  value       = aws_db_instance.this.port
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret storing PostgreSQL credentials."
  value       = aws_secretsmanager_secret.master.arn
}

output "security_group_id" {
  description = "Security group protecting the PostgreSQL instance."
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "DB subnet group used by the PostgreSQL instance."
  value       = aws_db_subnet_group.this.name
}
