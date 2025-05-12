data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

module "vns-va" {
  source = "./vns-va"

  environment               = data.terraform_remote_state.vpc.outputs.environment
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets            = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_subnets.*
  public_subnets_cidr       = data.terraform_remote_state.vpc.outputs.public_subnet_cidr_blocks
  private_subnets_cidr      = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
  key_name                  = data.terraform_remote_state.vpc.outputs.key_name
  public_key                = data.terraform_remote_state.vpc.outputs.public_key
  vns_token                 = var.vns_token
  pgo_vns_subnet_no         = 0
}


module "instances" {
  source = "./instances"

  environment                     = data.terraform_remote_state.vpc.outputs.environment
  vpc_id                          = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets                  = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_subnets                 = data.terraform_remote_state.vpc.outputs.private_subnets.*
  public_subnets_cidr             = data.terraform_remote_state.vpc.outputs.public_subnet_cidr_blocks
  private_subnets_cidr            = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
  private_security_group_id       = data.terraform_remote_state.vpc.outputs.private_security_group_id
  key_name                        = data.terraform_remote_state.vpc.outputs.key_name
  public_key                      = data.terraform_remote_state.vpc.outputs.public_key
  vns_va_traffic_mirror_filter_id = try(module.vns-va.vns_va_traffic_mirror_filter_id, "")
  vns_va_traffic_mirror_target_id = try(module.vns-va.vns_va_traffic_mirror_target_private_id, "")
}
