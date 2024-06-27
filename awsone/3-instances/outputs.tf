output "instance_ip_linux_web" {
  value = module.ec2.instance_ip_linux_web
}

output "instance_ip_linux_db" {
  value = module.ec2.instance_ip_linux_db
}

output "instance_username_linux_server" {
  value = module.ec2.instance_username_linux_server
}

output "instance_ip_windows_server" {
  value = module.ec2.instance_ip_windows_server
}

output "instance_username_windows_server" {
  value     = module.ec2.instance_username_windows_server
}

output "instance_password_windows_server" {
  value     = module.ec2.instance_password_windows_server
  sensitive = true
}

output "instance_password_windows_server_local" {
  value     = module.ec2.instance_password_windows_server_local
  sensitive = true
}

output "s3_bucket" {
  value = module.s3.s3_bucket
}

output "ssh_instance_linux_db" {
  value = module.ec2.ssh_instance_linux_db
}

output "ssh_instance_linux_web" {
  value = module.ec2.ssh_instance_linux_web
}

output "ssh_instance_windows_server" {
  value = module.ec2.ssh_instance_windows_server
}

output "pgo_dbadmin_access_key" {
  value = module.iam.pgo_dbadmin_access_key
}

output "pgo_dbadmin_secret_access_key" {
  value     = module.iam.pgo_dbadmin_secret_access_key
  sensitive = true
}
