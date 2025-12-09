variable "project_name" {
  description = "Project name used for naming and tagging."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Environment name, for example dev, staging, or prod."
  type        = string
}

variable "cluster_name" {
  description = "Exact EKS cluster name used for subnet discovery tags."
  type        = string
}

variable "cidr_block" {
  description = "Primary CIDR block for the VPC. A /16 works well with the built-in subnet split."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to spread the VPC across."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count == 3
    error_message = "This showcase module is intentionally sized for exactly three Availability Zones."
  }
}

variable "single_nat_gateway" {
  description = "Whether to create a single shared NAT gateway instead of one NAT gateway per Availability Zone."
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames inside the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS resolution inside the VPC."
  type        = bool
  default     = true
}

variable "flow_log_retention_in_days" {
  description = "Retention period for VPC flow logs stored in CloudWatch Logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to VPC resources."
  type        = map(string)
  default     = {}
}
