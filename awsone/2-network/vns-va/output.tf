# #############################################################################
# Outputs
# #############################################################################
output "vns_va_pip" {
  value = var.pgo_vns_private_ip
}

output "vns_va_ssh" {
  value = "ssh -o StrictHostKeyChecking=no admin@${var.pgo_vns_private_ip}"
}

output "vns_va_ami" {
  value = data.aws_ami.vns_va.id
}

output "vns_va_traffic_mirror_filter_id" {
  value = aws_ec2_traffic_mirror_filter.vns_traffic_filter.id
}

output "vns_va_traffic_mirror_target_private_id" {
  value = aws_ec2_traffic_mirror_target.vns_traffic_filter_target_private.id
}

output "vns_va_traffic_mirror_target_public_id" {
  value = aws_ec2_traffic_mirror_target.vns_traffic_filter_target_public.id
}
