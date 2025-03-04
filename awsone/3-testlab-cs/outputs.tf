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

#
# Apex One
# 
output "apex_one_server_ip" {
  value = module.ec2.apex_one_server_ip
}

output "apex_one_central_ip" {
  value = module.ec2.apex_one_central_ip
}

output "apex_one_server_ssh" {
  value = module.ec2.apex_one_server_ssh
}

output "apex_one_central_ssh" {
  value = module.ec2.apex_one_central_ssh
}

#
# Windows Client
#
output "windows_client_ip" {
  value = module.ec2.windows_client_ip
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
