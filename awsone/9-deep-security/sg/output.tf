# #############################################################################
# Outputs
# #############################################################################
output "public_instance_ip_sg_va" {
  value = aws_instance.sg_va.public_ip
}

output "ssh_instance_sg_va" {
  description = "Command to ssh to instance sg_va"
  value       = "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no admin@${aws_instance.sg_va.public_ip}"
}
