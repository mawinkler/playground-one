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
  private_key_path            = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile                 = module.iam.ec2_profile
  s3_bucket                   = module.s3.s3_bucket
  windows_ad_domain_name      = try(data.terraform_remote_state.vpc.outputs.ad_domain_name, "")
  windows_ad_user_name        = try(data.terraform_remote_state.vpc.outputs.ad_domain_admin, "")
  windows_ad_safe_password    = try(data.terraform_remote_state.vpc.outputs.ad_admin_password, "")
  windows_domain_member_count = 2
  linux_username              = var.linux_username
  windows_username            = var.windows_username
  create_linux                = var.create_linux
  linux_hostname              = "linuxdocker"
}

module "iam" {
  source = "./iam"

  environment = var.environment
  aws_region  = var.aws_region
  s3_bucket   = module.s3.s3_bucket
}

module "s3" {
  source = "./s3"

  environment = var.environment
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
