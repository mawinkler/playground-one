data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ec2" {
  source = "./ec2"

  environment              = var.environment
  public_security_group_id = data.terraform_remote_state.vpc.outputs.public_security_group_id
  public_subnets           = data.terraform_remote_state.vpc.outputs.public_subnets.*
  key_name                 = data.terraform_remote_state.vpc.outputs.key_name
  public_key               = data.terraform_remote_state.vpc.outputs.public_key
  private_key_path         = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile              = module.iam.ec2_profile
  s3_bucket                = module.s3.s3_bucket
  windows_username         = var.windows_username
  create_apex_one_server   = var.create_apex_one_server
  create_apex_one_central  = var.create_apex_one_central
  windows_client_count     = var.windows_client_count

  # PGO Active Directory
  active_directory         = var.active_directory
  windows_ad_domain_name   = try(data.terraform_remote_state.vpc.outputs.ad_domain_name, "")
  windows_ad_user_name     = try(data.terraform_remote_state.vpc.outputs.ad_domain_admin, "")
  windows_ad_safe_password = try(data.terraform_remote_state.vpc.outputs.ad_admin_password, "")
}

module "iam" {
  source = "./iam"

  environment = var.environment
  aws_region  = var.aws_region
  s3_bucket   = module.s3.s3_bucket
  # ssm_key     = data.terraform_remote_state.vpc.outputs.ssm_key
}

module "s3" {
  source = "./s3"

  environment = var.environment
}
