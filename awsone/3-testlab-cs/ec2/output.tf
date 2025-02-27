# #############################################################################
# Outputs
# #############################################################################
# Windows
output "apex_one_server_ip" {
  value = length(aws_instance.apex_one_server) > 0 ? aws_instance.apex_one_server[0].public_ip : null
}

output "apex_one_central_ip" {
  value = length(aws_instance.apex_one_central) > 0 ? aws_instance.apex_one_central[0].public_ip : null
}

output "win_username" {
  value = length(aws_instance.apex_one_central) > 0 ? var.active_directory ? "Administrator" : var.windows_username : null
}

output "win_password" {
  value = length(aws_instance.apex_one_central) > 0 ? var.active_directory ? var.windows_ad_safe_password : random_password.windows_password.result : null
}

output "win_local_admin_password" {
  value = length(aws_instance.apex_one_central) > 0 ? random_password.windows_password.result : null
}

output "apex_one_server_ssh" {
  description = "Command to ssh to instance apex_one_server"
  value       = length(aws_instance.apex_one_server) > 0 ? formatlist("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@%s", aws_instance.apex_one_server[*].public_ip) : null
}

output "apex_one_central_ssh" {
  description = "Command to ssh to instance apex_one_central"
  value       = length(aws_instance.apex_one_central) > 0 ? formatlist("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@%s", aws_instance.apex_one_central[*].public_ip) : null
}
