# Terraform infrastructure for platform on AWS

This directory provisions the AWS foundation for the `zowalska/k8s-production-platform` project. The Kubernetes workloads, Argo CD applications, Helm charts, and in-cluster Vault configuration that live elsewhere in the repository are deployed onto the EKS clusters created here.

Terraform is responsible for:

- the shared remote-state backend bootstrap stack
- per-environment VPC, EKS, RDS, and ElastiCache infrastructure
- IRSA roles for Loki, Cluster Autoscaler, AWS Load Balancer Controller, and the EBS CSI driver
- the S3 bucket Loki uses for chunk storage

Terraform is **not** managing GHCR images or application-level secrets. Application secrets stay in Vault running inside the cluster. AWS Secrets Manager is only used here for infrastructure-generated secrets such as the RDS master password and Redis auth token.

## Layout

```text
terraform/
├── README.md
├── global/
│   └── backend-bootstrap/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── elasticache/
│   └── observability-irsa/
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

## Architecture

- Each environment gets its own VPC spanning three Availability Zones in `eu-central-1`.
- Public subnets host ingress-facing load balancers and NAT gateways.
- Private subnets host EKS worker nodes and Redis.
- Database subnets provide extra isolation for relational data services.
- EKS clusters are named exactly:
  - `platform-dev`
  - `platform-staging`
  - `platform-prod`
- RDS PostgreSQL stores the application database named `platform`.
- ElastiCache Redis backs BullMQ and API caching.
- Loki stores chunks in an S3 bucket and writes via IRSA.
- Cluster Autoscaler, AWS Load Balancer Controller, and EBS CSI each receive dedicated IAM roles for service accounts.

To keep a first apply dependency-free, the EKS module enables the `aws-ebs-csi-driver` add-on while also attaching the AWS-managed EBS CSI policy to the node IAM role. The dedicated IRSA role is still created and output so the add-on can be switched to strict IRSA in a follow-up apply if desired.

## Prerequisites

- Terraform `>= 1.6`
- AWS credentials with permission to manage:
  - S3
  - DynamoDB
  - VPC networking
  - EKS
  - IAM
  - RDS
  - ElastiCache
  - Secrets Manager
- Access to deploy the Kubernetes layer defined elsewhere in the repository after the clusters exist

## 1. Bootstrap the remote backend once

The backend bootstrap stack intentionally uses **local state** because it creates the shared S3 bucket and DynamoDB lock table that the environment stacks use later.

```bash
cd terraform/global/backend-bootstrap
terraform init
terraform apply
```

Default backend resources:

- S3 bucket: `platform-terraform-state`
- DynamoDB table: `platform-terraform-locks`

If you change those names in the bootstrap module inputs, update the `backend.tf` files in `terraform/environments/*` or pass matching `-backend-config` overrides during `terraform init`.

## 2. Run an environment

Example for development:

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Staging and production follow the same flow:

```bash
cd terraform/environments/staging
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

```bash
cd terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Module responsibilities

- `global/backend-bootstrap`
  - One-time creation of the Terraform state bucket and DynamoDB lock table
- `modules/vpc`
  - VPC, subnets, NAT, routing, and VPC flow logs
- `modules/eks`
  - EKS control plane, managed node groups, core add-ons, and IRSA-ready OIDC outputs
- `modules/rds`
  - PostgreSQL, subnet group, security group, parameter group, and master secret in Secrets Manager
- `modules/elasticache`
  - Redis replication group, subnet group, security group, and auth token in Secrets Manager
- `modules/observability-irsa`
  - Loki S3 bucket plus IRSA roles/policies for Loki, Cluster Autoscaler, AWS Load Balancer Controller, and EBS CSI

## Relationship to the Kubernetes layer

After Terraform creates the AWS infrastructure:

1. workloads are deployed into namespaces `platform-dev`, `platform-staging`, and `platform-prod`
2. the `api` service listens on port `3000` behind Kubernetes ingress/load balancers
3. the `worker` service consumes BullMQ jobs with no ingress exposure
4. Argo CD / Helm resources elsewhere in the repo install the in-cluster platform components

This separation keeps cloud infrastructure concerns in Terraform and application/runtime concerns in Kubernetes manifests.
