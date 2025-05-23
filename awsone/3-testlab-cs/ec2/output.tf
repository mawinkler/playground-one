# #############################################################################
# Outputs
# #############################################################################
#
# Windows
#
output "win_username" {
  value = var.active_directory ? "Administrator" : var.windows_username
}

output "win_password" {
  value = var.active_directory ? var.windows_ad_safe_password : null
}

#
# Apex One
#
output "apex_one_central_ip" {
  value = length(aws_instance.apex_one_central) > 0 ? aws_instance.apex_one_central[0].public_ip != "" ? aws_instance.apex_one_central[0].public_ip : null : null
}

output "apex_one_central_pip" {
  value = length(aws_instance.apex_one_central) > 0 ? aws_instance.apex_one_central[0].private_ip : null
}

output "apex_one_central_id" {
  value = length(aws_instance.apex_one_central) > 0 ? aws_instance.apex_one_central[0].id : null
}

output "apex_one_central_ssh" {
  description = "Command to ssh to instance apex_one_central"
  value       = length(aws_instance.apex_one_central) > 0 ? formatlist("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@%s", aws_instance.apex_one_central[0].public_ip != "" ? aws_instance.apex_one_central[*].public_ip : aws_instance.apex_one_central[*].private_ip) : null
}

output "apex_one_server_ip" {
  value = length(aws_instance.apex_one_server) > 0 ? aws_instance.apex_one_server[0].public_ip != "" ? aws_instance.apex_one_server[0].public_ip : null : null
}

output "apex_one_server_pip" {
  value = length(aws_instance.apex_one_server) > 0 ? aws_instance.apex_one_server[0].private_ip : null
}

output "apex_one_server_id" {
  value = length(aws_instance.apex_one_server) > 0 ? aws_instance.apex_one_server[0].id : null
}

output "apex_one_server_ssh" {
  description = "Command to ssh to instance apex_one_server"
  value       = length(aws_instance.apex_one_server) > 0 ? formatlist("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@%s", aws_instance.apex_one_server[0].public_ip != "" ? aws_instance.apex_one_server[*].public_ip : aws_instance.apex_one_server[*].private_ip) : null
}

#
# Windows Clients
#
output "windows_client_ip" {
  description = "Windows Client IP"
  value       = length(local.ami_list) > 0 ? aws_instance.windows_client[0].public_ip != "" ? [for i in range(length(local.ami_list)) : aws_instance.windows_client[i].public_ip] : null : null
}

output "windows_client_pip" {
  description = "Windows Client IP"
  value       = length(local.ami_list) > 0 ? [for i in range(length(local.ami_list)) : aws_instance.windows_client[i].private_ip] : null
}

output "windows_client_id" {
  description = "Windows Client IDs"
  value       = length(local.ami_list) > 0 ? [for i in range(length(local.ami_list)) : aws_instance.windows_client[i].id] : null
}

output "windows_client_ssh" {
  description = "Command to ssh to instance Windows Client"
  value       = length(local.ami_list) > 0 ? [for i in range(length(local.ami_list)) : format("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@%s", aws_instance.windows_client[i].public_ip != "" ? aws_instance.windows_client[i].public_ip : aws_instance.windows_client[i].private_ip)] : null
}
