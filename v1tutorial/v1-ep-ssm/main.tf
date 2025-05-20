data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "instances" {
  source = "./instances"

  environment               = var.environment
  public_subnets            = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_subnets.*
  # public_security_group_id  = data.terraform_remote_state.vpc.outputs.public_security_group_id
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
  key_name                  = data.terraform_remote_state.vpc.outputs.key_name
  public_key                = data.terraform_remote_state.vpc.outputs.public_key

  private_key_path          = data.terraform_remote_state.vpc.outputs.private_key_path
  s3_bucket                 = data.terraform_remote_state.vpc.outputs.s3_bucket
  linux_username            = var.linux_username
  windows_username          = var.windows_username
  windows_hostname          = "Windows-Server"
  linux_hostname            = "linuxsrv"
  linux_count               = var.linux_count
  windows_count             = var.windows_count
  agent_deploy              = var.agent_deploy
  agent_variant             = var.agent_variant
  windows_ad_user_name     = try(data.terraform_remote_state.vpc.outputs.ad_domain_admin, "")
  windows_ad_safe_password = try(data.terraform_remote_state.vpc.outputs.ad_admin_password, "")
}

module "s3" {
  source = "./s3"

  environment = var.environment
}
