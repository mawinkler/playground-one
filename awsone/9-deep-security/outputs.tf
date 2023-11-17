# #############################################################################
# Outputs
# #############################################################################
output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "public_security_group_id" {
#   value = module.ec2.public_security_group_id
# }

# output "private_security_group_id" {
#   value = module.ec2.private_security_group_id
# }

# output "public_subnets" {
#   value = module.vpc.public_subnets
# }

# output "public_subnet_cidr_blocks" {
#   value = module.vpc.public_subnet_cidr_blocks
# }

# output "private_subnets" {
#   value = module.vpc.private_subnets
# }

# output "private_subnet_cidr_blocks" {
#   value = module.vpc.private_subnet_cidr_blocks
# }

output "key_name" {
  value = module.ec2.key_name
}

# output "public_key" {
#   value = module.ec2.public_key
# }

output "private_key_path" {
  value = module.ec2.private_key_path
}

################################################################################
# Deep Security RDS Database
################################################################################
output "rds_name" {
  value = module.rds.rds_name
}

output "rds_address" {
  value = module.rds.rds_address
}

# output "database_subnets" {
#   value = module.vpc.database_subnets
# }

# output "database_subnet_cidr_blocks" {
#   value = module.vpc.database_subnet_cidr_blocks
# }

# output "database_subnet_group" {
#   value = module.vpc.database_subnet_group
# }

################################################################################
# Bastion
################################################################################
output "bastion_instance_id" {
  value = module.bastion.bastion_instance_id
}

output "bastion_instance_ip" {
  value = module.bastion.bastion_instance_ip
}

output "ssh_instance_bastion" {
  value = module.bastion.ssh_instance_bastion
}

################################################################################
# Deep Security
################################################################################
output "dsm_instance_id" {
  value = module.dsm.dsm_instance_id
}

output "dsm_instance_ip" {
  value = module.dsm.dsm_instance_ip
}

output "ssh_instance_dsm" {
  value = module.dsm.ssh_instance_dsm
}

output "dsm_url" {
  value = module.dsm.dsm_url
}
