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
  description = "AWS region where observability support resources are created."
  type        = string
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "Exact EKS cluster name used in IAM policy conditions and role naming."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider associated with the EKS cluster."
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC issuer URL associated with the EKS cluster."
  type        = string
}

variable "loki_bucket_name_override" {
  description = "Optional explicit S3 bucket name for Loki object storage. Leave null to derive one automatically."
  type        = string
  default     = null
}

variable "loki_service_account_namespace" {
  description = "Namespace of the Loki service account."
  type        = string
  default     = "observability"
}

variable "loki_service_account_name" {
  description = "Name of the Loki service account."
  type        = string
  default     = "loki"
}

variable "cluster_autoscaler_service_account_namespace" {
  description = "Namespace of the Cluster Autoscaler service account."
  type        = string
  default     = "kube-system"
}

variable "cluster_autoscaler_service_account_name" {
  description = "Name of the Cluster Autoscaler service account."
  type        = string
  default     = "cluster-autoscaler"
}

variable "aws_load_balancer_controller_service_account_namespace" {
  description = "Namespace of the AWS Load Balancer Controller service account."
  type        = string
  default     = "kube-system"
}

variable "aws_load_balancer_controller_service_account_name" {
  description = "Name of the AWS Load Balancer Controller service account."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "ebs_csi_service_account_namespace" {
  description = "Namespace of the EBS CSI controller service account."
  type        = string
  default     = "kube-system"
}

variable "ebs_csi_service_account_name" {
  description = "Name of the EBS CSI controller service account."
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "loki_noncurrent_version_expiration_days" {
  description = "How long to retain noncurrent Loki objects in S3."
  type        = number
  default     = 30
}

variable "loki_abort_incomplete_upload_days" {
  description = "How many days to keep incomplete multipart uploads in the Loki bucket."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags applied to observability resources."
  type        = map(string)
  default     = {}
}
