# #############################################################################
# Outputs
# #############################################################################
output "ad_domain_name" {
  value = var.active_directory ? data.terraform_remote_state.vpc.outputs.ad_domain_name : null
}

output "ad_dc_ip" {
  value = var.active_directory ? data.terraform_remote_state.vpc.outputs.ad_dc_ip : null
}

output "ad_dc_pip" {
  value = var.active_directory ? data.terraform_remote_state.vpc.outputs.ad_dc_pip : null
}

output "ad_ca_ip" {
  value = var.active_directory ? data.terraform_remote_state.vpc.outputs.ad_ca_ip : null
}

output "ad_domain_admin" {
  value = var.active_directory ? data.terraform_remote_state.vpc.outputs.ad_domain_admin : null
}

output "windows_dns_names" {
  value = module.ec2.*.windows_dns_names
}

output "windows_ips" {
  value = module.ec2.*.windows_ips
}

output "ad_admin_password" {
  value     = var.active_directory ? data.terraform_remote_state.vpc.outputs.ad_admin_password : null
  sensitive = true
}

output "windows_local_admin_password" {
  value     = module.ec2.*.local_admin_password[0]
  sensitive = true
}

output "windows_local_admin_username" {
  value     = "admin"
}

output "ad_users_dn" {
  value = "CN=Users,DC=${
    split(".", try(data.terraform_remote_state.vpc.outputs.ad_domain_name, ""))[0]},DC=${
  split(".", try(data.terraform_remote_state.vpc.outputs.ad_domain_name, ""))[1]}"
}

output "linux_ssh" {
  value = module.ec2.*.ssh_instance_linux_docker
}

output "linux_pip" {
  value = module.ec2.*.linux_pip
}