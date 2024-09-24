data "terraform_remote_state" "deep_security" {
  backend = "local"

  config = {
    path = "../9-deep-security/terraform.tfstate"
  }
}

module "dsm" {
  source = "./dsm"

  environment       = var.environment
  bastion_public_ip = data.terraform_remote_state.deep_security.outputs.bastion_public_ip

  providers = {
    restapi.dsrest = restapi.dsrest
  }
}

module "computers" {
  source = "./computers"

  environment              = var.environment
  public_subnets           = data.terraform_remote_state.deep_security.outputs.public_subnets
  public_security_group_id = data.terraform_remote_state.deep_security.outputs.public_security_group_id
  key_name                 = data.terraform_remote_state.deep_security.outputs.key_name
  private_key_path         = data.terraform_remote_state.deep_security.outputs.private_key_path
  public_key               = data.terraform_remote_state.deep_security.outputs.public_key
  ec2_profile              = data.terraform_remote_state.deep_security.outputs.ec2_profile
  s3_bucket                = data.terraform_remote_state.deep_security.outputs.s3_bucket

  create_linux        = var.create_linux
  create_windows      = var.create_windows
  linux_username_amzn = var.linux_username_amzn
  linux_username_ubnt = var.linux_username_ubnt
  linux_username_rhel = var.linux_username_rhel
  linux_policy_id     = module.dsm.linux_policy_id
  windows_username    = var.windows_username
  windows_policy_id   = module.dsm.windows_policy_id
  bastion_private_ip  = data.terraform_remote_state.deep_security.outputs.bastion_private_ip
}
