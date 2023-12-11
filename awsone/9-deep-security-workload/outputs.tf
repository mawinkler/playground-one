# #############################################################################
# Outputs
# #############################################################################
#
# Computers
#
output "public_instance_ip_linux1" {
  value = module.computers.public_instance_ip_linux1
}

output "public_instance_ip_linux2" {
  value = module.computers.public_instance_ip_linux2
}

output "ssh_instance_linux1" {
  value = module.computers.ssh_instance_linux1
}

output "ssh_instance_linux2" {
  value = module.computers.ssh_instance_linux2
}

output "ds_apikey" {
  value = data.terraform_remote_state.deep_security.outputs.ds_apikey
}
