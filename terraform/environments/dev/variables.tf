variable "project_name" {
  description = "Project name used for naming and tagging."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Environment name for this stack."
  type        = string
  default     = "dev"

  validation {
    condition     = var.environment == "dev"
    error_message = "The dev environment stack must use environment = \"dev\"."
  }
}

variable "region" {
  description = "AWS region for the environment."
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the development VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for the development environment."
  type        = bool
  default     = true
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.30"
}

variable "flow_log_retention_in_days" {
  description = "Retention period for VPC flow logs."
  type        = number
  default     = 30
}

variable "eks_log_retention_in_days" {
  description = "Retention period for EKS control plane logs."
  type        = number
  default     = 30
}

variable "on_demand_instance_types" {
  description = "Instance types for the on-demand node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "on_demand_min_size" {
  description = "Minimum on-demand node count."
  type        = number
  default     = 1
}

variable "on_demand_max_size" {
  description = "Maximum on-demand node count."
  type        = number
  default     = 2
}

variable "on_demand_desired_size" {
  description = "Desired on-demand node count."
  type        = number
  default     = 1
}

variable "spot_instance_types" {
  description = "Instance types for the spot node group."
  type        = list(string)
  default     = ["t3.medium", "t3a.medium"]
}

variable "spot_min_size" {
  description = "Minimum spot node count."
  type        = number
  default     = 0
}

variable "spot_max_size" {
  description = "Maximum spot node count."
  type        = number
  default     = 2
}

variable "spot_desired_size" {
  description = "Desired spot node count."
  type        = number
  default     = 1
}

variable "db_name" {
  description = "Application database name."
  type        = string
  default     = "platform"
}

variable "db_username" {
  description = "Master username for PostgreSQL."
  type        = string
  default     = "platform_admin"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.4"
}

variable "db_instance_class" {
  description = "RDS instance class for development."
  type        = string
  default     = "db.t4g.medium"
}

variable "db_allocated_storage" {
  description = "Allocated PostgreSQL storage in GiB."
  type        = number
  default     = 50
}

variable "db_max_allocated_storage" {
  description = "Maximum PostgreSQL autoscaled storage in GiB."
  type        = number
  default     = 100
}

variable "db_backup_retention_days" {
  description = "Automated backup retention for PostgreSQL."
  type        = number
  default     = 7
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for PostgreSQL."
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Protect the database from accidental deletion."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip the final snapshot when destroying the development database."
  type        = bool
  default     = true
}

variable "db_performance_insights_enabled" {
  description = "Enable Performance Insights for the development database."
  type        = bool
  default     = false
}

variable "redis_node_type" {
  description = "ElastiCache node type for development."
  type        = string
  default     = "cache.t4g.small"
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "redis_num_cache_clusters" {
  description = "Number of Redis nodes in development."
  type        = number
  default     = 1
}

variable "redis_multi_az_enabled" {
  description = "Enable Multi-AZ failover for Redis."
  type        = bool
  default     = false
}

variable "redis_snapshot_retention_limit" {
  description = "Redis snapshot retention in days."
  type        = number
  default     = 1
}

variable "loki_bucket_name_override" {
  description = "Optional override for the Loki S3 bucket name."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Apply mutable infrastructure changes immediately."
  type        = bool
  default     = true
}

variable "extra_tags" {
  description = "Additional tags applied to all AWS resources."
  type        = map(string)
  default     = {}
}
