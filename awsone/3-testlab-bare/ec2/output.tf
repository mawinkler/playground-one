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
