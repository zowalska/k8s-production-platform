variable "project_name" {
  description = "Project name used for naming and tagging."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Environment name for this stack."
  type        = string
  default     = "prod"

  validation {
    condition     = var.environment == "prod"
    error_message = "The prod environment stack must use environment = \"prod\"."
  }
}

variable "region" {
  description = "AWS region for the environment."
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the production VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "single_nat_gateway" {
  description = "Set to false to provision one NAT gateway per Availability Zone in production."
  type        = bool
  default     = false
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.30"
}

variable "flow_log_retention_in_days" {
  description = "Retention period for VPC flow logs."
  type        = number
  default     = 90
}

variable "eks_log_retention_in_days" {
  description = "Retention period for EKS control plane logs."
  type        = number
  default     = 90
}

variable "on_demand_instance_types" {
  description = "Instance types for the on-demand node group."
  type        = list(string)
  default     = ["m6i.xlarge"]
}

variable "on_demand_min_size" {
  description = "Minimum on-demand node count."
  type        = number
  default     = 3
}

variable "on_demand_max_size" {
  description = "Maximum on-demand node count."
  type        = number
  default     = 6
}

variable "on_demand_desired_size" {
  description = "Desired on-demand node count."
  type        = number
  default     = 3
}

variable "spot_instance_types" {
  description = "Instance types for the spot node group."
  type        = list(string)
  default     = ["m6i.xlarge", "m5.xlarge", "m5a.xlarge"]
}

variable "spot_min_size" {
  description = "Minimum spot node count."
  type        = number
  default     = 1
}

variable "spot_max_size" {
  description = "Maximum spot node count."
  type        = number
  default     = 5
}

variable "spot_desired_size" {
  description = "Desired spot node count."
  type        = number
  default     = 2
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
  description = "RDS instance class for production."
  type        = string
  default     = "db.r6g.large"
}

variable "db_allocated_storage" {
  description = "Allocated PostgreSQL storage in GiB."
  type        = number
  default     = 200
}

variable "db_max_allocated_storage" {
  description = "Maximum PostgreSQL autoscaled storage in GiB."
  type        = number
  default     = 500
}

variable "db_backup_retention_days" {
  description = "Automated backup retention for PostgreSQL."
  type        = number
  default     = 14
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for PostgreSQL."
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Protect the database from accidental deletion."
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Skip the final snapshot when destroying the production database."
  type        = bool
  default     = false
}

variable "db_performance_insights_enabled" {
  description = "Enable Performance Insights for the production database."
  type        = bool
  default     = true
}

variable "redis_node_type" {
  description = "ElastiCache node type for production."
  type        = string
  default     = "cache.r6g.large"
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "redis_num_cache_clusters" {
  description = "Number of Redis nodes in production."
  type        = number
  default     = 2
}

variable "redis_multi_az_enabled" {
  description = "Enable Multi-AZ failover for Redis."
  type        = bool
  default     = true
}

variable "redis_snapshot_retention_limit" {
  description = "Redis snapshot retention in days."
  type        = number
  default     = 7
}

variable "loki_bucket_name_override" {
  description = "Optional override for the Loki S3 bucket name."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Apply mutable infrastructure changes immediately."
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "Additional tags applied to all AWS resources."
  type        = map(string)
  default     = {}
}
