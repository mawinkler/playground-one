# #############################################################################
# Outputs
# #############################################################################
#
# Linux
#
output "linux_ip" {
  value = length(aws_instance.linux-server) > 0 ? aws_instance.linux-server[0].public_ip != "" ? aws_instance.linux-server[0].public_ip : null : null
}

output "linux_pip" {
  value = length(aws_instance.linux-server) > 0 ? aws_instance.linux-server[0].private_ip : null
}

output "linux_username" {
  value = length(aws_instance.linux-server) > 0 ? var.linux_username : null
}

output "linux_ssh" {
  description = "Command to ssh to instance linux-server"
  value = length(aws_instance.linux-server) > 0 ? [
    for i in range(length(aws_instance.linux-server)) : format(
      "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.linux_username}@%s",
      coalesce(aws_instance.linux-server[i].public_ip, aws_instance.linux-server[i].private_ip)
    )
  ] : null
}

#
# Windows
#
output "windows_ip" {
  value = length(aws_instance.windows-server) > 0 ? aws_instance.windows-server[0].public_ip : null
}

output "windows_pip" {
  value = length(aws_instance.windows-server) > 0 ? aws_instance.windows-server[0].private_ip : null
}

output "windows_username" {
  value = length(aws_instance.windows-server) > 0 ? var.windows_username : null
}

output "windows_password" {
  value = length(aws_instance.windows-server) > 0 ? var.windows_ad_safe_password : null
}

output "windows_ssh" {
  description = "Command to ssh to instance windows-server"
  value = length(aws_instance.windows-server) > 0 ? [
    for i in range(length(aws_instance.windows-server)) : format(
      "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@%s",
      coalesce(aws_instance.windows-server[i].public_ip, aws_instance.windows-server[i].private_ip)
    )
  ] : null
}
