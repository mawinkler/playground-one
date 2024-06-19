output "mad_id" {
  value = aws_directory_service_directory.ds_managed_ad.id
}

output "mad_ips" {
  value = aws_directory_service_directory.ds_managed_ad.dns_ip_addresses
}

output "mad_secret_id" {
  value = aws_secretsmanager_secret.mad_admin_secret.id
}

output "mad_admin_password" {
    value = random_password.mad_admin_password.result
    sensitive = true
}