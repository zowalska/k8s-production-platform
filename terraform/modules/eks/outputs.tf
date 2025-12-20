output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster."
  value       = data.aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the EKS cluster."
  value       = data.aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider associated with the EKS cluster."
  value       = module.eks.oidc_provider_arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA trust policies."
  value       = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_primary_security_group_id" {
  description = "Primary security group attached to the EKS control plane."
  value       = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  description = "Shared security group attached to the EKS managed node groups."
  value       = module.eks.node_security_group_id
}
