# #############################################################################
# Outputs
# #############################################################################
# Instance
output "instance_id_linux" {
  value = aws_instance.linux.id
}

output "instance_ip_linux" {
  value = aws_instance.linux.public_ip
}
