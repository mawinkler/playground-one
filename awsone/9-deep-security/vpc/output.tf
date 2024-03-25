# #############################################################################
# Outputs
# #############################################################################
output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "azs" {
#   value = local.azs
# }

# output "azs_available" {
#   value = data.aws_availability_zones.available
# }

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnet_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnet_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "database_subnet_cidr_blocks" {
  value = module.vpc.database_subnets_cidr_blocks
}

output "database_subnet_group" {
  value = module.vpc.database_subnet_group
}
