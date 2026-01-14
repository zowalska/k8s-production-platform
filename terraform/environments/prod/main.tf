provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  environment  = var.environment
  cluster_name = "${var.project_name}-${local.environment}"

  common_tags = merge(
    var.extra_tags,
    {
      Project     = var.project_name
      Environment = local.environment
      ManagedBy   = "terraform"
      Repository  = "zowalska/k8s-production-platform"
    }
  )
}

module "vpc" {
  source = "../../modules/vpc"

  project_name               = var.project_name
  environment                = local.environment
  cluster_name               = local.cluster_name
  cidr_block                 = var.vpc_cidr
  single_nat_gateway         = var.single_nat_gateway
  flow_log_retention_in_days = var.flow_log_retention_in_days
  tags                       = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  project_name                     = var.project_name
  environment                      = local.environment
  region                           = var.region
  cluster_name                     = local.cluster_name
  cluster_version                  = var.cluster_version
  vpc_id                           = module.vpc.vpc_id
  private_subnet_ids               = module.vpc.private_subnet_ids
  control_plane_subnet_ids         = module.vpc.private_subnet_ids
  cloudwatch_log_retention_in_days = var.eks_log_retention_in_days

  on_demand_instance_types = var.on_demand_instance_types
  on_demand_min_size       = var.on_demand_min_size
  on_demand_max_size       = var.on_demand_max_size
  on_demand_desired_size   = var.on_demand_desired_size

  spot_instance_types = var.spot_instance_types
  spot_min_size       = var.spot_min_size
  spot_max_size       = var.spot_max_size
  spot_desired_size   = var.spot_desired_size

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project_name                 = var.project_name
  environment                  = local.environment
  region                       = var.region
  identifier                   = "${var.project_name}-${local.environment}-postgres"
  vpc_id                       = module.vpc.vpc_id
  subnet_ids                   = concat(module.vpc.private_subnet_ids, module.vpc.database_subnet_ids)
  allowed_security_group_ids   = [module.eks.cluster_primary_security_group_id, module.eks.node_security_group_id]
  db_name                      = var.db_name
  username                     = var.db_username
  engine_version               = var.db_engine_version
  instance_class               = var.db_instance_class
  allocated_storage            = var.db_allocated_storage
  max_allocated_storage        = var.db_max_allocated_storage
  backup_retention_period      = var.db_backup_retention_days
  multi_az                     = var.db_multi_az
  deletion_protection          = var.db_deletion_protection
  skip_final_snapshot          = var.db_skip_final_snapshot
  performance_insights_enabled = var.db_performance_insights_enabled
  apply_immediately            = var.apply_immediately
  tags                         = local.common_tags
}

module "elasticache" {
  source = "../../modules/elasticache"

  project_name               = var.project_name
  environment                = local.environment
  region                     = var.region
  replication_group_id       = "${var.project_name}-${local.environment}-redis"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.eks.cluster_primary_security_group_id, module.eks.node_security_group_id]
  node_type                  = var.redis_node_type
  engine_version             = var.redis_engine_version
  num_cache_clusters         = var.redis_num_cache_clusters
  multi_az_enabled           = var.redis_multi_az_enabled
  snapshot_retention_limit   = var.redis_snapshot_retention_limit
  apply_immediately          = var.apply_immediately
  tags                       = local.common_tags
}

# The EKS module enables the EBS CSI add-on on the first apply. This module still
# creates the dedicated IRSA role so the controller can be moved to strict
# service-account permissions in a follow-up apply without redesigning the stack.
module "observability_irsa" {
  source = "../../modules/observability-irsa"

  project_name              = var.project_name
  environment               = local.environment
  region                    = var.region
  cluster_name              = module.eks.cluster_name
  oidc_provider_arn         = module.eks.oidc_provider_arn
  oidc_provider_url         = module.eks.oidc_issuer_url
  loki_bucket_name_override = var.loki_bucket_name_override
  tags                      = local.common_tags
}
