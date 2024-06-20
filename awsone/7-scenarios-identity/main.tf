data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}


# module "mad" {
#   count = var.managed_active_directory ? 1 : 0

#   source = "./mad"

#   environment     = var.environment
#   vpc_id          = module.vpc.vpc_id
#   private_subnets = module.vpc.private_subnets
#   public_subnets  = module.vpc.public_subnets
# }

module "ec2" {
  count = var.active_directory ? 1 : 0

  source = "./ec2"

  environment = var.environment
  # vpc_id                      = module.vpc.vpc_id
  private_subnets          = data.terraform_remote_state.vpc.outputs.private_subnets
  public_subnets           = data.terraform_remote_state.vpc.outputs.public_subnets
  public_security_group_id = data.terraform_remote_state.vpc.outputs.public_security_group_id
  key_name                 = data.terraform_remote_state.vpc.outputs.key_name
  windows_ad_domain_name   = "${var.environment}.local"
  # windows_ad_nebios_name      = "ADFS"
  windows_ad_user_name        = "Administrator"
  windows_ad_safe_password    = "TrendMicro.1"
  windows_domain_member_count = 1
}

module "ad" {
  count = var.active_directory ? 1 : 0

  source = "./ad"

  environment = var.environment
  # vpc_id                      = module.vpc.vpc_id
}
