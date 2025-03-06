# Active Directory
output "ad_domain_name" {
  value = data.terraform_remote_state.vpc.outputs.ad_domain_name
}

output "ad_dc_ip" {
  value = data.terraform_remote_state.vpc.outputs.ad_dc_ip
}

output "ad_dc_pip" {
  value = data.terraform_remote_state.vpc.outputs.ad_dc_pip
}

output "ad_ca_ip" {
  value = data.terraform_remote_state.vpc.outputs.ad_ca_ip
}

output "ad_domain_admin" {
  value = data.terraform_remote_state.vpc.outputs.ad_domain_admin
}

output "ad_admin_password" {
  value     = data.terraform_remote_state.vpc.outputs.ad_admin_password
  sensitive = true
}

# Linux
output "linux_ip_web" {
  value = module.ec2.linux_ip_web
}

output "linux_ip_db" {
  value = module.ec2.linux_ip_db
}

output "linux_username" {
  value = module.ec2.linux_username
}

output "linux_ssh_db" {
  value = module.ec2.linux_ssh_db
}

output "linux_ssh_web" {
  value = module.ec2.linux_ssh_web
}

# Windows
output "win_ip" {
  value = module.ec2.win_ip
}

output "win_pip" {
  value = module.ec2.win_pip
}

output "win_username" {
  value = module.ec2.win_username
}

output "win_password" {
  value     = module.ec2.win_password
  sensitive = true
}

output "win_local_admin_password" {
  value     = module.ec2.win_local_admin_password
  sensitive = true
}

output "win_ssh" {
  value = module.ec2.win_ssh
}


# S3
output "s3_bucket" {
  value = module.s3.s3_bucket
}

# Attack Path
output "linux_ip_pap" {
  value = var.create_attackpath ? module.pap[0].linux_ip_pap : null
}

output "linux_ssh_pap" {
  value = var.create_attackpath ? module.pap[0].linux_ssh_pap : null
}

output "rds_identifier" {
  value = var.create_attackpath ? module.pap[0].rds_identifier : null
}

output "rds_arn" {
  value = var.create_attackpath ? module.pap[0].rds_arn : null
}

output "pgo_dbadmin_access_key" {
  value = var.create_attackpath ? module.pap[0].pgo_dbadmin_access_key : null
}

output "pgo_dbadmin_secret_access_key" {
  value     = var.create_attackpath ? module.pap[0].pgo_dbadmin_secret_access_key : null
  sensitive = true
}
