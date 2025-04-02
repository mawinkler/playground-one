# #############################################################################
# Outputs
# #############################################################################
output "public_instance_ip_vns_va" {
  value = var.pgo_vns_private_ip # aws_eip.vns_va_public_ip.public_ip
}

output "ssh_instance_vns_va" {
  description = "Command to ssh to instance vns_va"
  # value       = "ssh -o StrictHostKeyChecking=no admin@${aws_eip.vns_va_public_ip.public_ip}"
  value = "ssh -o StrictHostKeyChecking=no admin@${var.pgo_vns_private_ip}"
}

output "vns_va_ami" {
  value = data.aws_ami.vns_va.id
}

output "vns_va_traffic_mirror_filter_id" {
  value = aws_ec2_traffic_mirror_filter.vns_traffic_filter.id
}

output "vns_va_traffic_mirror_target_id" {
  value = aws_ec2_traffic_mirror_target.vns_traffic_filter_target.id
}
