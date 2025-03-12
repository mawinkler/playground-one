# #############################################################################
# Outputs
# #############################################################################
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

output "win_local_admin_password" {
  value     = module.ec2.win_local_admin_password
  sensitive = true
}

# Active Directory
output "ad_domain_name" {
  value = data.terraform_remote_state.vpc.outputs.ad_domain_name
}

output "ad_dc_ip" {
  value = data.terraform_remote_state.vpc.outputs.ad_dc_ip
}

output "ad_dc_pip" {
  value = data.terraform_remote_state.vpc.outputs.ad_dc_pip
}

output "ad_ca_ip" {
  value = data.terraform_remote_state.vpc.outputs.ad_ca_ip
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
output "apex_one_central_ip" {
  value = module.ec2.apex_one_central_ip
}

output "apex_one_central_id" {
  value = module.ec2.apex_one_central_id
}

output "apex_one_central_ssh" {
  value = module.ec2.apex_one_central_ssh
}

output "apex_one_server_ip" {
  value = module.ec2.apex_one_server_ip
}

output "apex_one_server_id" {
  value = module.ec2.apex_one_server_id
}

output "apex_one_server_ssh" {
  value = module.ec2.apex_one_server_ssh
}

#
# Windows Client
#
output "windows_client_ip" {
  value = module.ec2.windows_client_ip
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
  value = module.s3.s3_bucket
}

output "userdata_windows_client" {
  value     = module.ec2.userdata_windows_client
  sensitive = true
}

#
# Bastion
#
output "bastion_public_ip" {
  value = length(module.bastion) > 0 ? module.bastion[0].bastion_public_ip : null
}

output "bastion_private_ip" {
  value = length(module.bastion) > 0 ? module.bastion[0].bastion_private_ip : null
}

#
# RDS
#
output "rds_address" {
  value = length(module.rds) > 0 ? module.rds[0].rds_address : null
}

#
# Deep Security Manager
#
output "ssh_instance_dsm" {
  value = length(module.dsm) > 0 ? module.dsm[0].ssh_instance_dsm : null
}

output "dsm_url" {
  value = length(module.dsm) > 0 ? module.dsm[0].dsm_url : null
}

output "ds_apikey" {
  value = length(module.dsm) > 0 ? module.dsm[0].ds_apikey : null
}

output "dsm_private_ip" {
  value = "10.0.0.${random_integer.dsm_ip_octet.result}"
}
