# #############################################################################
# Outputs
# #############################################################################
output "member_dns_names" {
  value = aws_instance.windows-server-member.*.public_dns
}

output "local_admin_password" {
  # value = length(aws_instance.windows-server-member) > 0 ? random_password.windows_password.result : null
  value = "${random_password.windows_password.result}"
  sensitive = true
}
