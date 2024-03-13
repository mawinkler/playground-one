data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "eks-fargate" {
  source                    = "./eks-fargate"
  environment               = var.environment
  aws_region                = var.aws_region
  access_ip                 = var.access_ip
  key_name                  = data.terraform_remote_state.vpc.outputs.key_name
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_subnets.*
  intra_subnets             = data.terraform_remote_state.vpc.outputs.intra_subnets.*
}
