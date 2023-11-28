# #############################################################################
# Outputs
# #############################################################################
output "dsm_instance_id" {
  description = "DSM instance id"
  value       = aws_instance.dsm.id
}

output "ssh_instance_dsm" {
  description = "Command to ssh to instance dsm"
  value       = "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no -o ProxyCommand='ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ubuntu@${var.bastion_public_ip}' ec2-user@${aws_instance.dsm.private_ip}"
}

output "dsm_url" {
  description = "Deep Security Manager url"
  value       = "https://${var.bastion_public_ip}:4119"
}

output "ds_apikey" {
  value = data.local_file.apikey.content
}
