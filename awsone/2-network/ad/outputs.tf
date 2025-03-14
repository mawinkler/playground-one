output "ad_dc_ip" {
  value = aws_instance.windows-server-dc.public_ip != "" ? aws_instance.windows-server-dc.public_ip : null
}

output "ad_dc_pip" {
  value = aws_instance.windows-server-dc.private_ip
}

output "ad_dc_id" {
  value = aws_instance.windows-server-dc.id
}

output "ad_ca_ip" {
  value = aws_instance.windows-server-ca.public_ip != "" ? aws_instance.windows-server-ca.public_ip : null
}

output "ad_ca_pip" {
  value = aws_instance.windows-server-ca.private_ip
}

output "ad_ca_id" {
  value = aws_instance.windows-server-ca.id
}

output "ad_admin_password" {
  value     = var.windows_ad_safe_password
  sensitive = true
}
