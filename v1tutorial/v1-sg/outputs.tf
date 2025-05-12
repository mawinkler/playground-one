# #############################################################################
# Outputs
# #############################################################################
output "sg_va_va_pip" {
  value = module.sg-va.sg_va_pip
}

output "sg_va_ssh" {
  value = "ssh -i ${data.terraform_remote_state.vpc.outputs.private_key_path} -o StrictHostKeyChecking=no admin@${module.sg-va.sg_va_pip}"
}

output "sg_va_ami" {
  value = module.sg-va.sg_va_ami
}
