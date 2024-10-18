# #############################################################################
# Outputs
# #############################################################################
# Active Directory
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

output "ad_admin_password" {
  value     = var.active_directory ? data.terraform_remote_state.vpc.outputs.ad_admin_password : null
  sensitive = true
}

output "ad_users_dn" {
  value = "CN=Users,DC=${
    split(".", try(data.terraform_remote_state.vpc.outputs.ad_domain_name, ""))[0]},DC=${
  split(".", try(data.terraform_remote_state.vpc.outputs.ad_domain_name, ""))[1]}"
}

# Windows
output "win_dns_names" {
  value = module.ec2.*.win_dns_names
}

output "win_ips" {
  value = module.ec2.*.win_ips
}

output "win_pips" {
  value = module.ec2.*.win_pips
}

output "win_local_admin_password" {
  value     = module.ec2.*.win_local_admin_password[0]
  sensitive = true
}

output "win_local_admin_username" {
  value = "admin"
}

# Linux
output "linux_ssh" {
  value = module.ec2.*.ssh_instance_linux_docker
}

output "linux_pip" {
  value = module.ec2.*.linux_pip
}
