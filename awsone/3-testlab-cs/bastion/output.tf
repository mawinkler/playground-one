# #############################################################################
# Outputs
# #############################################################################
output "bastion_instance_id" {
  description = "Bastion instance id"
  value       = length(aws_instance.bastion) > 0 ? aws_instance.bastion.id : null
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = length(aws_instance.bastion) > 0 ? aws_instance.bastion.public_ip : null
}

output "bastion_private_ip" {
  description = "Bastion private IP"
  value       = length(aws_instance.bastion) > 0 ? aws_instance.bastion.private_ip : null
}

output "ssh_instance_bastion" {
  description = "Command to ssh to instance bastion"
  value       = length(aws_instance.bastion) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.bastion.public_ip}" : null
}
