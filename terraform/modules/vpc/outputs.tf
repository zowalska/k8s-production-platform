output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "Primary CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by this VPC."
  value       = module.vpc.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnets
}

output "database_subnet_ids" {
  description = "Database subnet IDs."
  value       = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  description = "Database subnet group created by the VPC module."
  value       = module.vpc.database_subnet_group_name
}
