data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project_name}-${var.environment}"

  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnets = [
    for index in range(var.az_count) : cidrsubnet(var.cidr_block, 4, index)
  ]

  private_subnets = [
    for index in range(var.az_count) : cidrsubnet(var.cidr_block, 4, index + var.az_count)
  ]

  database_subnets = [
    for index in range(var.az_count) : cidrsubnet(var.cidr_block, 4, index + (var.az_count * 2))
  ]

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = var.cidr_block

  azs              = local.azs
  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.database_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_traffic_type                = "ALL"
  flow_log_max_aggregation_interval    = 60

  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_retention_in_days

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Tier                                        = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Tier                                        = "private"
  }

  database_subnet_tags = {
    Tier = "database"
  }

  tags = local.common_tags
}
