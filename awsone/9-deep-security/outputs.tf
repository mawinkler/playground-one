# #############################################################################
# Outputs
# #############################################################################
#
# VPC
#
output "vpc_id" {
  value = module.vpc.vpc_id
}

#
# Key
#
output "key_name" {
  value = module.ec2.key_name
}

output "private_key_path" {
  value = module.ec2.private_key_path
}

#
# Deep Security RDS Database
#
output "rds_identifier" {
  value = module.rds.rds_identifier
}

output "rds_address" {
  value = module.rds.rds_address
}

#
# Bastion
#
output "bastion_instance_id" {
  value = module.bastion.bastion_instance_id
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "ssh_instance_bastion" {
  value = module.bastion.ssh_instance_bastion
}

#
# Deep Security
#
output "dsm_instance_id" {
  value = module.dsm.dsm_instance_id
}

output "ssh_instance_dsm" {
  value = module.dsm.ssh_instance_dsm
}

output "dsm_url" {
  value = module.dsm.dsm_url
}

#
# Computers
#
output "public_instance_ip_linux1" {
  value = module.computers.public_instance_ip_linux1
}

output "ssh_instance_linux1" {
  value = module.computers.ssh_instance_linux1
}

output "ds_apikey" {
  value = module.dsm.ds_apikey
}
