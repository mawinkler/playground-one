data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

module "network" {
  source               = "./vpc"
  access_ip            = var.access_ip
  environment          = var.environment
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr             = local.vpc_cidr
  public_subnets_cidr  = local.public_subnets_cidr
  private_subnets_cidr = local.private_subnets_cidr
}

module "ec2" {
  source          = "./ec2"
  environment     = var.environment
  one_path        = var.one_path
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  security_groups = local.security_groups
}
