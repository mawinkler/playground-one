# #############################################################################
# Outputs
# #############################################################################
output "bastion_instance_id" {
  description = "Bastion instance id"
  value       = aws_instance.bastion.id
}

output "bastion_instance_ip" {
  description = "Bastion instance IP"
  value       = aws_instance.bastion.public_ip
}

output "ssh_instance_bastion" {
  description = "Command to ssh to instance bastion"
  value       = "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.bastion.public_ip}"
}
