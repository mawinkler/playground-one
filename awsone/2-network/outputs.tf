#
# VPC
#
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_owner_id" {
  value = module.vpc.vpc_owner_id
}

# Security Groups
output "public_security_group_id" {
  value = module.ec2.public_security_group_id
}

output "private_security_group_id" {
  value = module.ec2.private_security_group_id
}

# SSM
# output "ssm_key" {
#   value = module.ec2.ssm_key
# }

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
# NAT Gateway
#
output "nat_ip" {
  value = module.vpc.nat_ip
}

#
# PGO VPN Gateway
#
output "vpn_client_conf_admin" {
  value = var.vpn_gateway ? module.vpn[0].vpn_client_conf_admin : null
}

output "vpn_server_ip" {
  value = var.vpn_gateway ? module.vpn[0].vpn_server_ip : null
}

output "vpn_server_id" {
  value = var.vpn_gateway ? module.vpn[0].vpn_server_id : null
}

output "vpn_up_admin" {
  value = var.vpn_gateway ? module.vpn[0].vpn_up_admin : null
}

output "vpn_conf_admin" {
  value = var.vpn_gateway ? module.vpn[0].vpn_conf_admin : null
}

#
# Active Directory
#
output "ad_domain_name" {
  value = var.active_directory ? var.ad_domain_name : null
}

output "ad_dc_ip" {
  value = var.active_directory ? module.ad[0].ad_dc_ip : null
}

output "ad_dc_id" {
  value = var.active_directory ? module.ad[0].ad_dc_id : null
}

output "ad_dc_pip" {
  value = var.active_directory ? module.ad[0].ad_dc_pip : null
}

output "ad_ca_ip" {
  value = var.active_directory ? module.ad[0].ad_ca_ip : null
}

output "ad_ca_pip" {
  value = var.active_directory ? module.ad[0].ad_ca_pip : null
}

output "ad_ca_id" {
  value = var.active_directory ? module.ad[0].ad_ca_id : null
}

output "ad_domain_admin" {
  value = var.active_directory ? var.ad_domain_admin : null
}

output "ad_admin_password" {
  value     = var.ad_admin_password
  sensitive = true
}

#
# Managed Active Directory
#
output "mad_ips" {
  value = var.managed_active_directory ? module.mad[0].mad_ips : null
}

output "mad_secret_id" {
  value = var.managed_active_directory ? module.mad[0].mad_secret_id : null
}

output "mad_admin_password" {
  value     = var.managed_active_directory ? module.mad[0].mad_admin_password : null
  sensitive = true
}

#
# Service Gateway
#
output "sg_va_pip" {
  value = var.service_gateway ? module.sg-va[0].instance_sg_va_pip : null
}

output "sg_va_ssh" {
  description = "Command to ssh to instance sg_va"
  value       = var.service_gateway ? module.sg-va[0].ssh_instance_sg_va : null
}

output "sg_va_ami" {
  value = var.service_gateway ? module.sg-va[0].sg_ami : null
}

#
# Virtual Network Sensor
#
output "vns_va_pip" {
  value = var.virtual_network_sensor ? module.vns-va[0].vns_va_pip : null
}

output "vns_va_ssh" {
  description = "Command to ssh to instance vns_va"
  value       = var.virtual_network_sensor ? module.vns-va[0].vns_va_ssh : null
}

output "vns_va_ami" {
  value = var.virtual_network_sensor ? module.vns-va[0].vns_va_ami : null
}

output "vns_va_traffic_mirror_filter_id" {
  value = var.virtual_network_sensor ? module.vns-va[0].vns_va_traffic_mirror_filter_id : null
}

output "vns_va_traffic_mirror_target_id" {
  value = var.virtual_network_sensor ? module.vns-va[0].vns_va_traffic_mirror_target_id : null
}

#
# Deep Discovery Inspector
#
output "ddi_va_pip" {
  value = var.deep_discovery_inspector ? module.ddi-va[0].ddi_va_pip : null
}

output "ddi_va_pip_managementport" {
  value = var.deep_discovery_inspector ? module.ddi-va[0].ddi_va_pip_managementport : null
}

output "ddi_va_ami" {
  value = var.deep_discovery_inspector ? module.ddi-va[0].ddi_ami : null
}

output "ddi_va_traffic_mirror_filter_id" {
  value = var.deep_discovery_inspector ? module.ddi-va[0].ddi_va_traffic_mirror_filter_id : null
}

output "ddi_va_traffic_mirror_target_id" {
  value = var.deep_discovery_inspector ? module.ddi-va[0].ddi_va_traffic_mirror_target_id : null
}
