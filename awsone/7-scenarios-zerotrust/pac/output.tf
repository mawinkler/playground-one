# #############################################################################
# Outputs
# #############################################################################
output "public_instance_id_pac_va" {
  value = aws_instance.pac_va.id
}

output "public_instance_ip_pac_va" {
  value = aws_instance.pac_va.public_ip
}

output "ssh_instance_pac_va" {
  description = "Command to ssh to instance pac_va"
  value       = "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no admin@${aws_instance.pac_va.public_ip}"
}

output "pac_ami" {
  value = data.aws_ami.pac_va.id
}
