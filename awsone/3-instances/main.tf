data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ec2" {
  source = "./ec2"

  environment                   = var.environment
  public_security_group_id      = data.terraform_remote_state.vpc.outputs.public_security_group_id
  public_security_group_inet_id = data.terraform_remote_state.vpc.outputs.public_security_group_inet_id
  public_subnets                = data.terraform_remote_state.vpc.outputs.public_subnets.*
  key_name                      = data.terraform_remote_state.vpc.outputs.key_name
  public_key                    = data.terraform_remote_state.vpc.outputs.public_key
  private_key_path              = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile                   = module.iam.ec2_profile
  ec2_profile_db                = module.iam.ec2_profile_db
  s3_bucket                     = module.s3.s3_bucket
  linux_username                = var.linux_username
  windows_username              = var.windows_username
  windows_hostname              = "Windows-Server"
  create_linux                  = var.create_linux
  linux_db_hostname             = "linuxdb"
  linux_web_hostname            = "linuxweb"
  linux_pap_hostname            = "linuxpap"
  create_windows                = var.create_windows
  create_attackpath             = var.create_attackpath

  # PGO Active Directory
  active_directory         = var.active_directory
  windows_ad_domain_name   = try(data.terraform_remote_state.vpc.outputs.ad_domain_name, "")
  windows_ad_user_name     = try(data.terraform_remote_state.vpc.outputs.ad_domain_admin, "")
  windows_ad_safe_password = try(data.terraform_remote_state.vpc.outputs.ad_admin_password, "")
}

module "iam" {
  source = "./iam"

  environment       = var.environment
  s3_bucket         = module.s3.s3_bucket
  create_attackpath = var.create_attackpath
}

module "s3" {
  source = "./s3"

  environment = var.environment
}

module "rds" {
  count = var.create_database ? 1 : 0

  source = "./rds"

  environment               = var.environment
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
  database_subnet_group     = data.terraform_remote_state.vpc.outputs.database_subnet_group
  rds_name                  = var.rds_name
  rds_username              = var.rds_username
}
