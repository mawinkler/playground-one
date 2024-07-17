# #############################################################################
# Main
# #############################################################################
data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "credentials" {
  source = "./credentials"

  environment = var.environment
}

module "target" {
  source = "./target"

  environment          = var.environment
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  access_ip            = var.access_ip
  public_subnets       = data.terraform_remote_state.vpc.outputs.public_subnets.*
  linux_username       = var.linux_username
  linux_hostname       = "target"
}

module "s3" {
  depends_on = [ module.target ]

  source = "./s3"

  environment = var.environment
}

data "external" "attack" {
  depends_on = [module.credentials, module.target, module.s3]

  program = ["bash", "${path.module}/attack.sh", "${var.environment}"]
}
