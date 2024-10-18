# #############################################################################
# Outputs
# #############################################################################
# Linux
# output "instance_id_linux_web" {
#   value = length(aws_instance.linux-web) > 0 ? aws_instance.linux-web[0].id : null
# }

output "linux_ip_web" {
  value = length(aws_instance.linux-web) > 0 ? aws_instance.linux-web[0].public_ip : null
}

# output "instance_id_linux_db" {
#   value = length(aws_instance.linux-db) > 0 ? aws_instance.linux-db[0].id : null
# }

output "linux_ip_db" {
  value = length(aws_instance.linux-db) > 0 ? aws_instance.linux-db[0].public_ip : null
}

output "linux_username" {
  value = length(aws_instance.linux-web) > 0 ? var.linux_username : null
}

# output "instance_id_windows_server" {
#   value = length(aws_instance.windows-server) > 0 ? aws_instance.windows-server[0].id : null
# }

output "linux_ssh_db" {
  description = "Command to ssh to instance linux-db"
  value       = length(aws_instance.linux-db) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.linux-db[0].public_ip}" : null
}

output "linux_ssh_web" {
  description = "Command to ssh to instance linux-web"
  value       = length(aws_instance.linux-web) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.linux-web[0].public_ip}" : null
}

# Windows
output "win_ip" {
  value = length(aws_instance.windows-server) > 0 ? aws_instance.windows-server[0].public_ip : null
}

output "win_pip" {
  value = length(aws_instance.windows-server) > 0 ? aws_instance.windows-server[0].private_ip : null
}

output "win_username" {
  value = length(aws_instance.windows-server) > 0 ? var.active_directory ? "Administrator" : var.windows_username : null
}

output "win_password" {
  value = length(aws_instance.windows-server) > 0 ? var.active_directory ? var.windows_ad_safe_password : random_password.windows_password.result : null
}

output "win_local_admin_password" {
  value = length(aws_instance.windows-server) > 0 ? random_password.windows_password.result : null
}

output "win_ssh" {
  description = "Command to ssh to instance windows-server"
  value       = length(aws_instance.windows-server) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@${aws_instance.windows-server[0].public_ip}" : null
}
