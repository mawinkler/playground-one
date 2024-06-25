data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ecs-ec2" {
  source                     = "./ecs-ec2"
  
  environment                = var.environment
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
