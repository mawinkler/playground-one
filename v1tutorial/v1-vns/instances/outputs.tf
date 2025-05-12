# #############################################################################
# Outputs
# #############################################################################
#
# Linux
#
output "linux_pip" {
  value = length(aws_instance.linux-server) > 0 ? [for i in range(length(aws_instance.linux-server)) : aws_instance.linux-server[i].private_ip] : null
}

output "linux_username" {
  value = length(aws_instance.linux-server) > 0 ? var.linux_username : null
}

#
# Windows
#
output "windows_pip" {
  value = length(aws_instance.windows-server) > 0 ? [for i in range(length(aws_instance.windows-server)) : aws_instance.windows-server[i].private_ip] : null
}

output "windows_username" {
  value = length(aws_instance.windows-server) > 0 ? var.windows_username : null
}

output "windows_password" {
  value = length(aws_instance.windows-server) > 0 ? var.windows_ad_safe_password : null
}
