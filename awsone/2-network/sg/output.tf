# #############################################################################
# Outputs
# #############################################################################
output "instance_sg_va_id" {
  value = aws_instance.sg_va.id
}

output "instance_sg_va_pip" {
  value = var.pgo_sg_private_ip
}

output "ssh_instance_sg_va" {
  description = "Command to ssh to instance sg_va"
  value       = "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no admin@${var.pgo_sg_private_ip}"
}

output "sg_ami" {
  value = aws_instance.sg_va.ami
}
