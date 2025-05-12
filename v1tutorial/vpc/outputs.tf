# #############################################################################
# Outputs
# #############################################################################
#
# VPC
#
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_owner_id" {
  value = module.vpc.vpc_owner_id
}

output "environment" {
  value = var.environment
}

# Security Groups
output "public_security_group_id" {
  value = module.ec2.public_security_group_id
}

output "private_security_group_id" {
  value = module.ec2.private_security_group_id
}

#
# Subnets
#
output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_subnet_cidr_blocks" {
  value = module.vpc.public_subnet_cidr_blocks
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "private_subnet_cidr_blocks" {
  value = module.vpc.private_subnet_cidr_blocks
}

output "intra_subnets" {
  value = module.vpc.intra_subnets
}

output "intra_subnet_cidr_blocks" {
  value = module.vpc.intra_subnet_cidr_blocks
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "database_subnet_group" {
  value = module.vpc.database_subnet_group
}

#
# Key pair
#
output "key_name" {
  value = module.ec2.key_name
}

output "public_key" {
  value = module.ec2.public_key
}

output "private_key" {
  value     = module.ec2.private_key
  sensitive = true
}

output "private_key_path" {
  value = module.ec2.private_key_path
}

#
# PGO VPN Gateway
#
output "vpn_client_conf_admin" {
  value = module.vpn.vpn_client_conf_admin
}

output "vpn_server_ip" {
  value = module.vpn.vpn_server_ip
}

output "vpn_server_id" {
  value = module.vpn.vpn_server_id
}

output "vpn_up_admin" {
  value = module.vpn.vpn_up_admin
}

output "vpn_conf_admin" {
  value = module.vpn.vpn_conf_admin
}
