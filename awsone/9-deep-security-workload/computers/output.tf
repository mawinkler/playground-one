# #############################################################################
# Outputs
# #############################################################################
output "public_instance_id_linux1" {
  value = length(aws_instance.linux1) > 0 ? aws_instance.linux1[0].id : ""
}

output "public_instance_ip_linux1" {
  value = length(aws_instance.linux1) > 0 ? aws_instance.linux1[0].public_ip : ""
}

output "ssh_instance_linux1" {
  description = "Command to ssh to instance linux1"
  value       = length(aws_instance.linux1) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.linux_username}@${aws_instance.linux1[0].public_ip}" : ""
}

# output "windows_password" {
#   value = random_password.windows_password.result
# }
