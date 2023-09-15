data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ec2" {
  source                   = "./ec2"
  environment              = var.environment
  public_security_group_id = data.terraform_remote_state.vpc.outputs.public_security_group_id
  public_subnet_ids        = data.terraform_remote_state.vpc.outputs.public_subnet_ids.*
  key_name                 = data.terraform_remote_state.vpc.outputs.key_name
  public_key               = data.terraform_remote_state.vpc.outputs.public_key
  private_key_path         = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile              = module.iam.ec2_profile
  s3_bucket                = module.s3.s3_bucket
  linux_username           = var.linux_username
  windows_username         = var.windows_username
  create_linux             = var.create_linux
  create_windows           = var.create_windows
}

module "iam" {
  source      = "./iam"
  environment = var.environment
  s3_bucket   = module.s3.s3_bucket
}

module "s3" {
  source = "./s3"
  environment = var.environment
}
