# #############################################################################
# Outputs
# #############################################################################
output "public_instance_ip_linux1" {
  value = length(aws_instance.linux1) > 0 ? aws_instance.linux1[*].public_ip : null
}

output "public_instance_ip_linux2" {
  value = length(aws_instance.linux2) > 0 ? aws_instance.linux2[*].public_ip : null
}

output "public_instance_ip_windows1" {
  value = length(aws_instance.windows1) > 0 ? aws_instance.windows1[*].public_ip : null
}

output "ssh_instance_linux1" {
  description = "Command to ssh to instance linux1"
  value       = length(aws_instance.linux1) > 0 ? formatlist("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.linux_username_amzn}@%s", aws_instance.linux1[*].public_ip) : null
}

output "ssh_instance_linux2" {
  description = "Command to ssh to instance linux2"
  value       = length(aws_instance.linux1) > 0 ? formatlist("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.linux_username_ubnt}@%s", aws_instance.linux2[*].public_ip) : null
}

output "ssh_instance_windows1" {
  description = "Command to ssh to instance windows1"
  value       = length(aws_instance.windows1) > 0 ? formatlist("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.windows_username}@%s", aws_instance.windows1[*].public_ip) : null
}

output "windows_password" {
  value = random_password.windows_password.result
}
