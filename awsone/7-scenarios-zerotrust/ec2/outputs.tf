# #############################################################################
# Outputs
# #############################################################################
output "windows_dns_names" {
  value = aws_instance.windows-server-member.*.public_dns
}

output "windows_ips" {
  value = aws_instance.windows-server-member.*.public_ip
}

output "linux_pip" {
  value = aws_instance.linux-docker.*.private_ip
}

output "local_admin_password" {
  # value = length(aws_instance.windows-server-member) > 0 ? random_password.windows_password.result : null
  value = "${random_password.windows_password.result}"
  sensitive = true
}

output "ssh_instance_linux_docker" {
  description = "Command to ssh to instance linux-docker"
  value       = length(aws_instance.linux-docker) > 0 ? formatlist("ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@%s", aws_instance.linux-docker[*].public_ip) : null
}
