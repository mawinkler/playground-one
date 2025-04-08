# #############################################################################
# Outputs
# #############################################################################
output "ddi_va_pip" {
  value = var.pgo_ddi_private_ip
}

# output "ddi_va_pip_dataport_public" {
#   value = aws_network_interface.ddi_va_ni_data_public0.private_ip
# }

# output "ddi_va_pip_dataport_private" {
#   value = aws_network_interface.ddi_va_ni_data_private.private_ip
# }

output "ddi_va_pip_managementport" {
  value = aws_network_interface.ddi_va_ni_management.private_ip
}

output "ddi_ami" {
  value = aws_instance.ddi_va.ami
}

output "ddi_va_traffic_mirror_filter_id" {
  value = aws_ec2_traffic_mirror_filter.ddi_traffic_filter.id
}

output "ddi_va_traffic_mirror_target_private_id" {
  value = aws_ec2_traffic_mirror_target.ddi_traffic_filter_target_private.id
}

output "ddi_va_traffic_mirror_target_public_id" {
  value = aws_ec2_traffic_mirror_target.ddi_traffic_filter_target_public.id
}
