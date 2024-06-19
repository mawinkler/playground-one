output "ad_ip" {
  value = aws_instance.windows-server-dc.public_ip
}

output "ca_ip" {
  value = aws_instance.windows-server-ca.public_ip
}

output "ad_admin_password" {
  value     = var.windows_ad_safe_password
  sensitive = true
}
