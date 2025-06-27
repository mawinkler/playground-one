data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "eks" {
  source                       = "./eks-ec2"
  environment                  = var.environment
  aws_region                   = var.aws_region
  access_ip                    = var.access_ip
  key_name                     = data.terraform_remote_state.vpc.outputs.key_name
  vpc_id                       = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_owner_id                 = data.terraform_remote_state.vpc.outputs.vpc_owner_id
  private_subnets              = data.terraform_remote_state.vpc.outputs.private_subnets.*
  intra_subnets                = data.terraform_remote_state.vpc.outputs.intra_subnets.*
  public_security_group_id     = data.terraform_remote_state.vpc.outputs.public_security_group_id
  private_security_group_id    = data.terraform_remote_state.vpc.outputs.private_security_group_id
  vpn_server_security_group_id = data.terraform_remote_state.vpc.outputs.vpn_server_security_group_id
}
