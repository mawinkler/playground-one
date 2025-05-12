# #############################################################################
# Outputs
# #############################################################################
output "sg_va_pip" {
  value = aws_network_interface.sg_va.private_ip
}

output "sg_va_ami" {
  value = aws_instance.sg_va.ami
}
