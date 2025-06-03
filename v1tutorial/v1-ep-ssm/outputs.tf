# #############################################################################
# Outputs
# #############################################################################
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

#
# S3
#
output "s3_bucket" {
  value = module.s3.s3_bucket
}
