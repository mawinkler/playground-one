# #############################################################################
# Outputs
# #############################################################################
output "dsm_instance_id" {
  description = "DSM instance id"
  value       = length(aws_instance.dsm) > 0 ? aws_instance.dsm.id : null
}

output "ssh_instance_dsm" {
  description = "Command to ssh to instance dsm"
  value       = length(aws_instance.dsm) > 0 ? "ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no -o ProxyCommand='ssh -i ${var.private_key_path} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ubuntu@${var.bastion_public_ip}' ec2-user@${aws_instance.dsm.private_ip}" : null
}

output "dsm_url" {
  description = "Deep Security Manager url"
  value       = length(aws_instance.dsm) > 0 ? "https://${var.bastion_public_ip}:4119" : null
}

output "dsm_purl" {
  description = "Deep Security Manager private url"
  value       = length(aws_instance.dsm) > 0 ? "https://${var.bastion_private_ip}:4119" : null
}

output "ds_apikey" {
  value = length(aws_instance.dsm) > 0 ? data.local_file.apikey.content : null
}
