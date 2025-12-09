variable "project_name" {
  description = "Project tag value applied to shared backend resources."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Pseudo-environment tag for shared backend resources."
  type        = string
  default     = "global"
}

variable "region" {
  description = "AWS region where the Terraform backend resources are created."
  type        = string
  default     = "eu-central-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform remote state."
  type        = string
  default     = "platform-terraform-state"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  type        = string
  default     = "platform-terraform-locks"
}

variable "force_destroy" {
  description = "Allow destroying the remote state bucket even when it still contains objects."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to backend resources."
  type        = map(string)
  default     = {}
}
