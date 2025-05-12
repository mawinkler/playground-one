# #############################################################################
# Outputs
# #############################################################################
output "vns_va_pip" {
  value = module.vns-va.vns_va_pip
}

output "vns_va_ssh" {
  value = "ssh -o StrictHostKeyChecking=no admin@${module.vns-va.vns_va_pip}"
}

output "vns_va_ami" {
  value = module.vns-va.vns_va_ami
}

output "vns_va_traffic_mirror_filter_id" {
  value = module.vns-va.vns_va_traffic_mirror_filter_id
}

output "vns_va_traffic_mirror_target_private_id" {
  value = module.vns-va.vns_va_traffic_mirror_target_private_id
}

output "vns_va_traffic_mirror_target_public_id" {
  value = module.vns-va.vns_va_traffic_mirror_target_public_id
}

#
# Instances
#
output "linux_pip" {
  value = module.instances.linux_pip
}

output "linux_ssh" {
  description = "Command to ssh to instance linux-server"
  value = length(module.instances.linux_pip) > 0 ? [
    for i in range(length(module.instances.linux_pip)) : format(
      "ssh -i ${data.terraform_remote_state.vpc.outputs.private_key_path} -o StrictHostKeyChecking=no ubuntu@%s",
    module.instances.linux_pip[i])
  ] : null
}

output "windows_pip" {
  value = module.instances.windows_pip
}

output "windows_ssh" {
  description = "Command to ssh to instance windows-server"
  value = length(module.instances.windows_pip) > 0 ? [
    for i in range(length(module.instances.windows_pip)) : format(
      "ssh -i ${data.terraform_remote_state.vpc.outputs.private_key_path} -o StrictHostKeyChecking=no administrator@%s",
    module.instances.windows_pip[i])
  ] : null
}
