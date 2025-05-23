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
  value = try(data.terraform_remote_state.vpc.outputs.ad_domain_name, null)
}

output "ad_dc_ip" {
  value = try(data.terraform_remote_state.vpc.outputs.ad_dc_ip, null)
}

output "ad_dc_pip" {
  value = try(data.terraform_remote_state.vpc.outputs.ad_dc_pip, null)
}

output "ad_ca_ip" {
  value = try(data.terraform_remote_state.vpc.outputs.ad_ca_ip, null)
}

output "ad_ca_pip" {
  value = try(data.terraform_remote_state.vpc.outputs.ad_ca_pip, null)
}

output "ad_domain_admin" {
  value = try(data.terraform_remote_state.vpc.outputs.ad_domain_admin, null)
}

output "ad_admin_password" {
  value     = data.terraform_remote_state.vpc.outputs.ad_admin_password
  sensitive = true
}

#
# Windows Client
#
output "windows_ip" {
  value = module.ec2.windows_client_ip
}

output "windows_pip" {
  value = module.ec2.windows_client_pip
}

output "windows_id" {
  value = module.ec2.windows_client_id
}

output "windows_ssh" {
  value = module.ec2.windows_client_ssh
}

#
# S3
#
output "s3_bucket" {
  value = data.terraform_remote_state.vpc.outputs.s3_bucket
}

output "windows_userdata" {
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
output "psql_pip" {
  description = "PostgreSQL private IP"
  value       = length(module.psql) > 0 ? module.psql[0].postgres_private_ip : null
}

output "psql_ssh" {
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

output "dsm_pip" {
  value = var.dsm_private_ip
}
