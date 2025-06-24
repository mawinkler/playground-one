# #############################################################################
# Outputs
# #############################################################################
output "vpc_id" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "public_security_group_id" {
  value = data.terraform_remote_state.vpc.outputs.public_security_group_id
}

output "private_security_group_id" {
  value = data.terraform_remote_state.vpc.outputs.private_security_group_id
}

#
# Windows
#
output "win_username" {
  value = module.ec2.win_username
}

output "win_password" {
  value     = module.ec2.win_password
  sensitive = true
}

# output "win_local_admin_password" {
#   value     = module.ec2.win_local_admin_password
#   sensitive = true
# }

# Active Directory
output "ad_domain_name" {
  value = data.terraform_remote_state.vpc.outputs.ad_domain_name
}

output "ad_dc_ip" {
  value = try(data.terraform_remote_state.vpc.outputs.ad_dc_ip, null)
}

output "ad_dc_pip" {
  value = data.terraform_remote_state.vpc.outputs.ad_dc_pip != "" ? data.terraform_remote_state.vpc.outputs.ad_dc_pip : null
}

output "ad_ca_ip" {
  value = try(data.terraform_remote_state.vpc.outputs.ad_ca_ip, null)
}

output "ad_ca_pip" {
  value = data.terraform_remote_state.vpc.outputs.ad_ca_pip != "" ? data.terraform_remote_state.vpc.outputs.ad_ca_pip : null
}

output "ad_domain_admin" {
  value = data.terraform_remote_state.vpc.outputs.ad_domain_admin
}

output "ad_admin_password" {
  value     = data.terraform_remote_state.vpc.outputs.ad_admin_password
  sensitive = true
}

#
# Apex One
# 
output "apex_central_ip" {
  value = module.ec2.apex_central_ip
}

output "apex_central_pip" {
  value = module.ec2.apex_central_pip
}

output "apex_central_id" {
  value = module.ec2.apex_central_id
}

output "apex_central_ssh" {
  value = module.ec2.apex_central_ssh
}

output "apex_one_ip" {
  value = module.ec2.apex_one_ip
}

output "apex_one_pip" {
  value = module.ec2.apex_one_pip
}

output "apex_one_id" {
  value = module.ec2.apex_one_id
}

output "apex_one_ssh" {
  value = module.ec2.apex_one_ssh
}

#
# Exchange
#
output "exchange_ip" {
  value = module.ec2.exchange_ip
}

output "exchange_pip" {
  value = module.ec2.exchange_pip
}

output "exchange_id" {
  value = module.ec2.exchange_id
}

output "exchange_ssh" {
  value = module.ec2.exchange_ssh
}

output "transport_ip" {
  value = module.ec2.transport_ip
}

output "transport_pip" {
  value = module.ec2.transport_pip
}

output "transport_id" {
  value = module.ec2.transport_id
}

output "transport_ssh" {
  value = module.ec2.transport_ssh
}

#
# Windows Client
#
output "windows_client_ip" {
  value = module.ec2.windows_client_ip
}

output "windows_client_pip" {
  value = module.ec2.windows_client_pip
}

output "windows_client_id" {
  value = module.ec2.windows_client_id
}

output "windows_client_ssh" {
  value = module.ec2.windows_client_ssh
}

#
# S3
#
output "s3_bucket" {
  value = data.terraform_remote_state.vpc.outputs.s3_bucket
}

output "userdata_windows_client" {
  value     = module.ec2.userdata_windows_client
  sensitive = true
}

#
# RDS
#
output "rds_address" {
  value = length(module.rds) > 0 ? module.rds[0].rds_address : null
}

#
# PostgreSQL
#
output "postgres_instance_id" {
  value = length(module.psql) > 0 ? module.psql[0].postgres_instance_id : null
}

output "postgres_private_ip" {
  description = "Bastion private IP"
  value       = length(module.psql) > 0 ? module.psql[0].postgres_private_ip : null
}

output "ssh_instance_postgres" {
  description = "Command to ssh to instance postgres"
  value       = length(module.psql) > 0 ? module.psql[0].ssh_instance_postgres : null
}

#
# Deep Security Manager
#
output "dsm_ssh" {
  value = length(module.dsm) > 0 ? module.dsm[0].ssh_instance_dsm : null
}

output "dsm_url" {
  value = length(module.dsm) > 0 ? module.dsm[0].dsm_purl : null
}

output "ds_apikey" {
  value = length(module.dsm) > 0 ? module.dsm[0].ds_apikey : null
}

output "dsm_private_ip" {
  value = var.dsm_private_ip
}
