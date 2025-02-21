# #############################################################################
# Outputs
# #############################################################################
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_owner_id" {
  value = module.vpc.vpc_owner_id
}

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

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "intra_subnet_cidr_blocks" {
  value = module.vpc.intra_subnets_cidr_blocks
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

# output "nat_ip" {
#   value = module.vpc.nat_public_ips[0]
# }
