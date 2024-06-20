# # Managed Active Directory
# output "mad_ips" {
#   value = var.managed_active_directory ? module.mad[0].mad_ips : null
# }

# output "mad_secret_id" {
#   value = var.managed_active_directory ? module.mad[0].mad_secret_id : null
# }

# output "mad_admin_password" {
#   value     = var.managed_active_directory ? module.mad[0].mad_admin_password : null
#   sensitive = true
# }

# # Active Directory
# output "ad_dc_ip" {
#   value = var.active_directory ? module.ad[0].ad_dc_ip : null
# }

# output "ad_ca_ip" {
#   value = var.active_directory ? module.ad[0].ad_ca_ip : null
# }

# output "ad_admin_password" {
#   value     = var.active_directory ? module.ad[0].ad_admin_password : null
#   sensitive = true
# }

output "computer_dns_names" {
  value = module.ec2[0].computer_dns_names
}
