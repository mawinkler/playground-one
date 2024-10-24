# #############################################################################
# Outputs
# #############################################################################
#
# VPC
#
output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "azs" {
#   value = module.vpc.azs
# }

# output "azs_available" {
#   value = module.vpc.azs_available
# }

output "public_subnets" {
  value = module.vpc.public_subnets
}

# output "private_subnets" {
#   value = module.vpc.private_subnets
# }

#
# EC2
#
output "public_security_group_id" {
  value = module.ec2.public_security_group_id
}

# output "private_security_group_id" {
#   value = module.ec2.private_security_group_id
# }

output "key_name" {
  value = module.ec2.key_name
}

output "private_key_path" {
  value = module.ec2.private_key_path
}

output "public_key" {
  value = module.ec2.public_key
}

#
# IAM
#
output "ec2_profile" {
  value = module.iam.ec2_profile
}

#
# S3
#
output "s3_bucket" {
  value = module.s3.s3_bucket
}

#
# Deep Security RDS Database
#
# output "rds_identifier" {
#   value = module.rds.rds_identifier
# }

# output "rds_address" {
#   value = module.rds.rds_address
# }

#
# Bastion
#
# output "bastion_instance_id" {
#   value = module.bastion.bastion_instance_id
# }

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "bastion_private_ip" {
  value = module.bastion.bastion_private_ip
}

# output "ssh_instance_bastion" {
#   value = module.bastion.ssh_instance_bastion
# }

#
# Deep Security
#
# output "dsm_instance_id" {
#   value = module.dsm.dsm_instance_id
# }

output "ssh_instance_dsm" {
  value = module.dsm.ssh_instance_dsm
}

output "dsm_url" {
  value = module.dsm.dsm_url
}

output "ds_apikey" {
  value = module.dsm.ds_apikey
}

output "dsm_private_ip" {
  value = "10.0.0.${random_integer.dsm_ip_octet.result}"
}

# Service Gateway
output "sg_va_ip" {
  value = var.service_gateway ? module.sg[0].public_instance_ip_sg_va : null
}

output "sg_va_ssh" {
  description = "Command to ssh to instance sg_va"
  value       = var.service_gateway ? module.sg[0].ssh_instance_sg_va : null
}
