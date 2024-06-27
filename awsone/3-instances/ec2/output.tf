# #############################################################################
# Outputs
# #############################################################################
output "instance_id_linux_web" {
  value = length(aws_instance.linux-web) > 0 ? aws_instance.linux-web[0].id : null
}

output "instance_ip_linux_web" {
  value = length(aws_instance.linux-web) > 0 ? aws_instance.linux-web[0].public_ip : null
}

output "instance_id_linux_db" {
  value = length(aws_instance.linux-db) > 0 ? aws_instance.linux-db[0].id : null
}

output "instance_ip_linux_db" {
  value = length(aws_instance.linux-db) > 0 ? aws_instance.linux-db[0].public_ip : null
}

output "instance_username_linux_server" {
  value = length(aws_instance.linux-web) > 0 ? var.linux_username : null
}

output "instance_id_windows_server" {
  value = length(aws_instance.windows-server) > 0 ? aws_instance.windows-server[0].id : null
}

output "instance_ip_windows_server" {
  value = length(aws_instance.windows-server) > 0 ? aws_instance.windows-server[0].public_ip : null
}

output "instance_username_windows_server" {
  value = length(aws_instance.windows-server) > 0 ? var.active_directory ? "Administrator" : var.windows_username : null
}

output "instance_password_windows_server" {
  value = length(aws_instance.windows-server) > 0 ? var.active_directory ? var.windows_ad_safe_password : random_password.windows_password.result : null
}

output "instance_password_windows_server_local" {
  value = length(aws_instance.windows-server) > 0 ? random_password.windows_password.result : null
}

output "ssh_instance_linux_db" {
  description = "Command to ssh to instance linux-db"
  value       = length(aws_instance.linux-db) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.linux-db[0].public_ip}" : null
}

output "ssh_instance_linux_web" {
  description = "Command to ssh to instance linux-web"
  value       = length(aws_instance.linux-web) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.linux-web[0].public_ip}" : null
}

output "ssh_instance_windows_server" {
  description = "Command to ssh to instance windows-server"
  value       = length(aws_instance.windows-server) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@${aws_instance.windows-server[0].public_ip}" : null
}
