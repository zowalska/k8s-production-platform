locals {
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  secret_name               = "${var.identifier}/master-credentials"
  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(var.final_snapshot_identifier, "${var.identifier}-final")
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+[]{}"
}

resource "aws_secretsmanager_secret" "master" {
  name        = local.secret_name
  description = "Master PostgreSQL credentials for ${var.identifier}."

  tags = merge(
    local.common_tags,
    {
      Name = local.secret_name
    }
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.identifier}-subnets"
    }
  )
}

resource "aws_security_group" "this" {
  name        = "${var.identifier}-sg"
  description = "Security group for ${var.identifier} PostgreSQL."
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.identifier}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "eks" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value
  description                  = "Allow PostgreSQL access from ${each.value}."
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.identifier}-postgres"
  family = var.parameter_group_family

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.identifier}-postgres"
    }
  )
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username
  password = random_password.master.result
  port     = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  multi_az            = var.multi_az
  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = local.final_snapshot_identifier
  copy_tags_to_snapshot     = true

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = var.performance_insights_enabled
  auto_minor_version_upgrade      = true
  publicly_accessible             = false

  tags = merge(
    local.common_tags,
    {
      Name = var.identifier
    }
  )
}

resource "aws_secretsmanager_secret_version" "master" {
  secret_id = aws_secretsmanager_secret.master.id

  secret_string = jsonencode(
    {
      engine         = "postgres"
      host           = aws_db_instance.this.address
      port           = var.port
      database       = var.db_name
      username       = var.username
      password       = random_password.master.result
      connection_uri = format("postgresql://%s:%s@%s:%d/%s", urlencode(var.username), urlencode(random_password.master.result), aws_db_instance.this.address, var.port, var.db_name)
    }
  )
}
