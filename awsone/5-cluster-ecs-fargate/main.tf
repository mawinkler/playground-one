data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ecs-fargate" {
  source                     = "./ecs-fargate"

  environment                = var.environment
  aws_region                 = var.aws_region
  access_ip                  = var.access_ip
  vpc_id                     = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets             = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_subnets            = data.terraform_remote_state.vpc.outputs.private_subnets.*
  private_subnet_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks.*
  private_security_group_id  = data.terraform_remote_state.vpc.outputs.private_security_group_id
}

