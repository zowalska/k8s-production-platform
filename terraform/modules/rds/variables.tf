variable "project_name" {
  description = "Project name used for naming and tagging."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Environment name, for example dev, staging, or prod."
  type        = string
}

variable "region" {
  description = "AWS region where the database is created."
  type        = string
  default     = "eu-central-1"
}

variable "identifier" {
  description = "Unique RDS instance identifier."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID that hosts the database security group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the DB subnet group."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnets across Availability Zones for the DB subnet group."
  }
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to PostgreSQL."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.allowed_security_group_ids) > 0
    error_message = "Provide at least one EKS-related security group ID that can reach PostgreSQL."
  }
}

variable "db_name" {
  description = "Application database name."
  type        = string
  default     = "platform"
}

variable "username" {
  description = "Master username for PostgreSQL."
  type        = string
  default     = "platform_admin"
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.medium"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 50
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage in GiB."
  type        = number
  default     = 200
}

variable "storage_type" {
  description = "RDS storage type."
  type        = string
  default     = "gp3"
}

variable "port" {
  description = "Port exposed by PostgreSQL."
  type        = number
  default     = 5432
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1
    error_message = "backup_retention_period must be at least 1 day."
  }
}

variable "backup_window" {
  description = "Preferred daily backup window in UTC."
  type        = string
  default     = "03:00-06:00"
}

variable "maintenance_window" {
  description = "Preferred weekly maintenance window in UTC."
  type        = string
  default     = "Mon:00:00-Mon:03:00"
}

variable "parameter_group_family" {
  description = "RDS parameter group family."
  type        = string
  default     = "postgres16"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the database."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot when the database is destroyed."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Optional final snapshot identifier used when skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Apply modifications immediately instead of waiting for the next maintenance window."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to database resources."
  type        = map(string)
  default     = {}
}
