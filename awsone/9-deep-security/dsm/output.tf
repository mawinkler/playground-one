# #############################################################################
# Outputs
# #############################################################################
output "dsm_instance_id" {
  description = "DSM instance id"
  value = aws_instance.dsm.id
}

output "dsm_instance_ip" {
  description = "DSM instance IP"
  value = aws_instance.dsm.public_ip
}

output "ssh_instance_dsm" {
  description = "Command to ssh to instance dsm"
  value       = "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no ec2-user@${aws_instance.dsm.public_ip}"
}

output "dsm_url" {
  description = "Deep Security Manager url"
  value       = "https://${aws_instance.dsm.public_dns}:4119"
}
