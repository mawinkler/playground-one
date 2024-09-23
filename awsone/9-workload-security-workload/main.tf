data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ws" {
  source = "./ws"

  environment = var.environment

  providers = {
    restapi.wsrest = restapi.wsrest
  }
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

module "computers" {
  source = "./computers"

  environment              = var.environment
  public_security_group_id = data.terraform_remote_state.vpc.outputs.public_security_group_id
  public_subnets           = data.terraform_remote_state.vpc.outputs.public_subnets.*
  key_name                 = data.terraform_remote_state.vpc.outputs.key_name
  public_key               = data.terraform_remote_state.vpc.outputs.public_key
  private_key_path         = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile              = module.iam.ec2_profile
  s3_bucket                = module.s3.s3_bucket

  ws_region           = var.ws_region
  ws_tenant_id        = var.ws_tenant_id
  ws_token            = var.ws_token
  create_linux        = var.create_linux
  create_windows      = var.create_windows
  linux_username_amzn = var.linux_username_amzn
  linux_username_ubnt = var.linux_username_ubnt
  linux_policy_id     = module.ws.linux_policy_id
  windows_username    = var.windows_username
  windows_policy_id   = module.ws.windows_policy_id
}
