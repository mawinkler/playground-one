data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "module-2" {
  source = "./module-2"

  environment           = var.environment
  aws_region            = var.aws_region
  access_ip             = var.access_ip
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  database_subnet_group = data.terraform_remote_state.vpc.outputs.database_subnet_group
  public_subnets        = data.terraform_remote_state.vpc.outputs.public_subnets.*
}
