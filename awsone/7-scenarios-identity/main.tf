data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ec2" {
  count = var.active_directory ? 1 : 0

  source = "./ec2"

  environment                 = var.environment
  private_subnets             = data.terraform_remote_state.vpc.outputs.private_subnets
  public_subnets              = data.terraform_remote_state.vpc.outputs.public_subnets
  public_security_group_id    = data.terraform_remote_state.vpc.outputs.public_security_group_id
  key_name                    = data.terraform_remote_state.vpc.outputs.key_name
  windows_ad_domain_name      = try(data.terraform_remote_state.vpc.outputs.ad_domain_name, "")
  windows_ad_user_name        = try(data.terraform_remote_state.vpc.outputs.ad_domain_admin, "")
  windows_ad_safe_password    = try(data.terraform_remote_state.vpc.outputs.ad_admin_password, "")
  windows_domain_member_count = 2
}

module "ad" {
  count = var.active_directory ? 1 : 0

  source = "./ad"

  environment            = var.environment
  windows_ad_domain_name = try(data.terraform_remote_state.vpc.outputs.ad_domain_name, "")
  users_dn = "CN=Users,DC=${
    split(".", try(data.terraform_remote_state.vpc.outputs.ad_domain_name, ""))[0]},DC=${
  split(".", try(data.terraform_remote_state.vpc.outputs.ad_domain_name, ""))[1]}"
  domain_admins_dn = "CN=Domain Admins,CN=Users,DC=${
    split(".", try(data.terraform_remote_state.vpc.outputs.ad_domain_name, ""))[0]},DC=${
  split(".", try(data.terraform_remote_state.vpc.outputs.ad_domain_name, ""))[1]}"
}
