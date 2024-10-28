# #############################################################################
# Outputs
# #############################################################################
output "ddi_va_ip" {
  value = aws_eip.ddi_va_public_ip.public_ip
}

output "ddi_va_pip_dataport_public" {
  value = aws_network_interface.ddi_va_ni_data_public.private_ip
}

# output "ddi_va_pip_dataport_private" {
#   value = aws_network_interface.ddi_va_ni_data_private.private_ip
# }

output "ddi_va_pip_managementport" {
  value = aws_network_interface.ddi_va_ni_management.private_ip
}

output "ddi_ami" {
  value = data.aws_ami.ddi_va.id
}

output "ddi_va_traffic_mirror_filter_id" {
  value = aws_ec2_traffic_mirror_filter.ddi_traffic_filter.id
}

output "ddi_va_traffic_mirror_target_id" {
  value = aws_ec2_traffic_mirror_target.ddi_traffic_filter_target.id
}
