# #############################################################################
# Outputs
# #############################################################################
output "public_instance_ip_vns_va" {
  value = aws_eip.vns_va_public_ip.public_ip
}

output "ssh_instance_vns_va" {
  description = "Command to ssh to instance vns_va"
  value       = "ssh -o StrictHostKeyChecking=no admin@${aws_eip.vns_va_public_ip.public_ip}"
}

output "vns_va_ami" {
  value = data.aws_ami.vns_va.id
}