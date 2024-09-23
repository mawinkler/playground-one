# #############################################################################
# Outputs
# #############################################################################
#
# Computers
#
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

output "ws_apikey" {
  value = var.ws_apikey
}

output "linux_policy_id" {
  value = module.ws.linux_policy_id
}

output "windows_policy_id" {
  value = module.ws.windows_policy_id
}
