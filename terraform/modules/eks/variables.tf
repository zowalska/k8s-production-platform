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
  description = "AWS region where the cluster is created."
  type        = string
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "Exact EKS cluster name."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  description = "VPC ID that hosts the EKS cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS worker nodes."
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "Subnet IDs used by the EKS control plane ENIs. Defaults to the worker private subnets when empty."
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_public_access" {
  description = "Expose the Kubernetes API publicly."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Expose the Kubernetes API privately inside the VPC."
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "EKS control plane log types exported to CloudWatch Logs."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_retention_in_days" {
  description = "Retention period for EKS control plane logs."
  type        = number
  default     = 30
}

variable "enable_irsa" {
  description = "Enable the cluster OIDC provider so IAM Roles for Service Accounts can be created."
  type        = bool
  default     = true
}

variable "node_ami_type" {
  description = "AMI type used by EKS managed node groups."
  type        = string
  default     = "AL2_x86_64"
}

variable "node_disk_size" {
  description = "Disk size in GiB for managed node groups."
  type        = number
  default     = 80
}

variable "on_demand_instance_types" {
  description = "Instance types used for the on-demand node group."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "on_demand_min_size" {
  description = "Minimum size of the on-demand managed node group."
  type        = number
  default     = 2
}

variable "on_demand_max_size" {
  description = "Maximum size of the on-demand managed node group."
  type        = number
  default     = 4
}

variable "on_demand_desired_size" {
  description = "Desired size of the on-demand managed node group."
  type        = number
  default     = 2
}

variable "spot_instance_types" {
  description = "Instance types used for the spot node group."
  type        = list(string)
  default     = ["m6i.large", "m5.large", "m5a.large"]
}

variable "spot_min_size" {
  description = "Minimum size of the spot managed node group."
  type        = number
  default     = 1
}

variable "spot_max_size" {
  description = "Maximum size of the spot managed node group."
  type        = number
  default     = 3
}

variable "spot_desired_size" {
  description = "Desired size of the spot managed node group."
  type        = number
  default     = 1
}

variable "ebs_csi_role_arn" {
  description = "Optional IRSA role ARN for the aws-ebs-csi-driver add-on. Leave null on a first apply to avoid circular dependencies."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to cluster resources."
  type        = map(string)
  default     = {}
}
