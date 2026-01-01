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
  description = "AWS region where Redis is created."
  type        = string
  default     = "eu-central-1"
}

variable "replication_group_id" {
  description = "Unique ElastiCache replication group identifier."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID that hosts the Redis security group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the ElastiCache subnet group."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnets across Availability Zones for the ElastiCache subnet group."
  }
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to Redis."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.allowed_security_group_ids) > 0
    error_message = "Provide at least one EKS-related security group ID that can reach Redis."
  }
}

variable "node_type" {
  description = "ElastiCache node type."
  type        = string
  default     = "cache.t4g.small"
}

variable "engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "parameter_group_family" {
  description = "ElastiCache parameter group family."
  type        = string
  default     = "redis7"
}

variable "num_cache_clusters" {
  description = "Number of cache nodes in the replication group."
  type        = number
  default     = 1

  validation {
    condition     = var.num_cache_clusters >= 1
    error_message = "num_cache_clusters must be at least 1."
  }
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ failover for Redis."
  type        = bool
  default     = false

  validation {
    condition     = !var.multi_az_enabled || var.num_cache_clusters >= 2
    error_message = "When multi_az_enabled is true, num_cache_clusters must be at least 2."
  }
}

variable "port" {
  description = "Port exposed by Redis."
  type        = number
  default     = 6379
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain automatic Redis snapshots."
  type        = number
  default     = 1
}

variable "snapshot_window" {
  description = "Preferred daily snapshot window in UTC."
  type        = string
  default     = "02:00-05:00"
}

variable "maintenance_window" {
  description = "Preferred weekly maintenance window in UTC."
  type        = string
  default     = "sun:03:00-sun:05:00"
}

variable "apply_immediately" {
  description = "Apply modifications immediately instead of waiting for the next maintenance window."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to ElastiCache resources."
  type        = map(string)
  default     = {}
}
