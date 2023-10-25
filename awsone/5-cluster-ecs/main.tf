data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ecs-ec2" {
  count = var.ecs_ec2 ? 1 : 0

  source                     = "./ecs-ec2"
  environment                = var.environment
  account_id                 = var.account_id
  aws_region                 = var.aws_region
  access_ip                  = var.access_ip
  key_name                   = data.terraform_remote_state.vpc.outputs.key_name
  vpc_id                     = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets             = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_subnets            = data.terraform_remote_state.vpc.outputs.private_subnets.*
  public_subnet_cidr_blocks  = data.terraform_remote_state.vpc.outputs.public_subnet_cidr_blocks.*
  private_subnet_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks.*
  private_security_group_id  = data.terraform_remote_state.vpc.outputs.private_security_group_id
}

module "ecs-fargate" {
  count = var.ecs_fargate ? 1 : 0

  source                     = "./ecs-fargate"
  environment                = var.environment
  account_id                 = var.account_id
  aws_region                 = var.aws_region
  access_ip                  = var.access_ip
  vpc_id                     = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets             = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_subnets            = data.terraform_remote_state.vpc.outputs.private_subnets.*
  private_subnet_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks.*
  private_security_group_id  = data.terraform_remote_state.vpc.outputs.private_security_group_id
}
