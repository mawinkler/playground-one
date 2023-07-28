data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "eks" {
  source                    = "./eks"
  environment               = var.environment
  account_id                = var.account_id
  aws_region                = var.aws_region
  key_name                  = data.terraform_remote_state.vpc.outputs.key_name
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids        = data.terraform_remote_state.vpc.outputs.private_subnet_ids.*
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
}
