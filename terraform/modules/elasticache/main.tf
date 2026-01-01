locals {
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  secret_name = "${var.replication_group_id}/auth-token"
}

resource "random_password" "auth_token" {
  length           = 40
  special          = true
  override_special = "!#$%&*()-_=+[]{}"
}

resource "aws_secretsmanager_secret" "redis" {
  name        = local.secret_name
  description = "Redis auth token and endpoint information for ${var.replication_group_id}."

  tags = merge(
    local.common_tags,
    {
      Name = local.secret_name
    }
  )
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.replication_group_id}-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.replication_group_id}-subnets"
    }
  )
}

resource "aws_security_group" "this" {
  name        = "${var.replication_group_id}-sg"
  description = "Security group for ${var.replication_group_id} Redis."
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.replication_group_id}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "eks" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value
  description                  = "Allow Redis access from ${each.value}."
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
}

resource "aws_elasticache_parameter_group" "this" {
  name   = "${var.replication_group_id}-redis"
  family = var.parameter_group_family

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.replication_group_id}-redis"
    }
  )
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.replication_group_id
  description          = "Redis for ${var.project_name} ${var.environment}."

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type

  num_cache_clusters = var.num_cache_clusters
  port               = var.port

  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids         = [aws_security_group.this.id]
  parameter_group_name       = aws_elasticache_parameter_group.this.name
  automatic_failover_enabled = var.multi_az_enabled
  multi_az_enabled           = var.multi_az_enabled

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.auth_token.result

  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  maintenance_window         = var.maintenance_window
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = true

  tags = merge(
    local.common_tags,
    {
      Name = var.replication_group_id
    }
  )
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id

  secret_string = jsonencode(
    {
      engine         = "redis"
      host           = aws_elasticache_replication_group.this.primary_endpoint_address
      port           = var.port
      auth_token     = random_password.auth_token.result
      connection_uri = format("rediss://:%s@%s:%d/0", urlencode(random_password.auth_token.result), aws_elasticache_replication_group.this.primary_endpoint_address, var.port)
    }
  )
}
