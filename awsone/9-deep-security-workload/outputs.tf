# #############################################################################
# Outputs
# #############################################################################
#
# Computers
#
# output "public_instance_ip_linux1" {
#   value = module.computers.public_instance_ip_linux1
# }

# output "public_instance_ip_linux2" {
#   value = module.computers.public_instance_ip_linux2
# }

# output "public_instance_ip_windows1" {
#   value = module.computers.public_instance_ip_windows1
# }

output "public_instance_password_windows1" {
  value     = module.computers.windows_password
  sensitive = true
}

output "ssh_instance_linux1" {
  value = module.computers.ssh_instance_linux1
}

output "ssh_instance_linux2" {
  value = module.computers.ssh_instance_linux2
}

output "ssh_instance_windows1" {
  value = module.computers.ssh_instance_windows1
}

output "dsm_url" {
  value = data.terraform_remote_state.deep_security.outputs.dsm_url
}

output "ds_apikey" {
  value = data.terraform_remote_state.deep_security.outputs.ds_apikey
}

# output "linux_policy_id" {
#   value = module.dsm.linux_policy_id
# }

# output "windows_policy_id" {
#   value = module.dsm.windows_policy_id
# }
