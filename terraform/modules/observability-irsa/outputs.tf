output "loki_bucket_name" {
  description = "Name of the S3 bucket used by Loki for object storage."
  value       = aws_s3_bucket.loki.bucket
}

output "loki_bucket_arn" {
  description = "ARN of the S3 bucket used by Loki for object storage."
  value       = aws_s3_bucket.loki.arn
}

output "loki_irsa_role_arn" {
  description = "IAM role ARN for the Loki service account."
  value       = aws_iam_role.loki.arn
}

output "cluster_autoscaler_irsa_role_arn" {
  description = "IAM role ARN for the Cluster Autoscaler service account."
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "aws_load_balancer_controller_irsa_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller service account."
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "ebs_csi_irsa_role_arn" {
  description = "IAM role ARN for the EBS CSI controller service account."
  value       = aws_iam_role.ebs_csi.arn
}
