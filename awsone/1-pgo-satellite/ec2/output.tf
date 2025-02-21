# #############################################################################
# Outputs
# #############################################################################
output "key_name" {
  value = aws_key_pair.key_pair.key_name
}

output "public_key" {
  value = trimspace(tls_private_key.key_pair.public_key_openssh)
}

output "private_key_path" {
  value = local_file.ssh_key.filename
}

output "public_security_group_id" {
  value = aws_security_group.sg["public"].id
}

output "private_security_group_id" {
  value = aws_security_group.sg["private"].id
}

output "pgo_satellite_ip" {
  value = length(aws_instance.pgo-satellite) > 0 ? aws_instance.pgo-satellite[0].public_ip : null
}

output "pgo_satellite_username" {
  value = length(aws_instance.pgo-satellite) > 0 ? var.linux_username : null
}

output "pgo_satellite_ssh" {
  description = "Command to ssh to instance pgo-satellite"
  value       = length(aws_instance.pgo-satellite) > 0 ? formatlist("ssh -i ${local_file.ssh_key.filename} -o StrictHostKeyChecking=no ${var.linux_username}@%s", aws_instance.pgo-satellite[*].public_ip) : null
}
