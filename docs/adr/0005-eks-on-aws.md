# 5. Amazon EKS as the Kubernetes runtime

## Status
Accepted

## Context
The platform needed one concrete, fully-specified cloud target for the
Terraform layer (VPC, managed Kubernetes control plane, managed Postgres,
managed Redis, IAM/IRSA) rather than staying cloud-agnostic in the abstract,
since IRSA, security groups, and managed-service wiring differ meaningfully
between clouds.

## Decision
AWS was chosen: EKS for Kubernetes, RDS for PostgreSQL, ElastiCache for
Redis, S3 for Loki's chunk storage, IAM Roles for Service Accounts (IRSA)
for pod-level AWS permissions (Loki, Cluster Autoscaler, AWS Load Balancer
Controller, EBS CSI driver).

## Consequences
- `terraform/modules/*` and `terraform/environments/*` are AWS-specific
  HCL, not an abstraction layer over multiple clouds.
- The Kubernetes/Helm/Argo CD layers above the cluster remain fairly
  portable (they don't call the AWS API directly), so re-targeting to
  GKE/AKS would mainly mean rewriting `terraform/` and the IRSA-specific
  annotations, not the application or GitOps layers.
