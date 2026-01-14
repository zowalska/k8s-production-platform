output "vpc_id" {
  description = "ID of the staging VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets for staging."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnets for staging."
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnets for staging."
  value       = module.vpc.database_subnet_ids
}

output "cluster_name" {
  description = "Staging EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Staging EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Staging EKS cluster certificate authority data."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for the staging EKS cluster."
  value       = module.eks.oidc_issuer_url
}

output "rds_endpoint" {
  description = "PostgreSQL endpoint for staging."
  value       = module.rds.endpoint
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN containing PostgreSQL credentials."
  value       = module.rds.secret_arn
}

output "redis_primary_endpoint" {
  description = "Primary Redis endpoint for staging."
  value       = module.elasticache.primary_endpoint
}

output "redis_secret_arn" {
  description = "Secrets Manager ARN containing the Redis auth token."
  value       = module.elasticache.secret_arn
}

output "loki_bucket_name" {
  description = "S3 bucket used by Loki in staging."
  value       = module.observability_irsa.loki_bucket_name
}

output "irsa_role_arns" {
  description = "IRSA role ARNs for the staging cluster."
  value = {
    loki                         = module.observability_irsa.loki_irsa_role_arn
    cluster_autoscaler           = module.observability_irsa.cluster_autoscaler_irsa_role_arn
    aws_load_balancer_controller = module.observability_irsa.aws_load_balancer_controller_irsa_role_arn
    ebs_csi                      = module.observability_irsa.ebs_csi_irsa_role_arn
  }
}
