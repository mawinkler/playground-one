# output "ad_dc_ip" {
#   value = aws_instance.windows-server-dc.public_ip
# }

# output "ad_ca_ip" {
#   value = aws_instance.windows-server-ca.public_ip
# }

# output "ad_admin_password" {
#   value     = var.windows_ad_safe_password
#   sensitive = true
# }

output "computer_dns_names" {
  value = aws_instance.windows-server-member[0].public_dns
}