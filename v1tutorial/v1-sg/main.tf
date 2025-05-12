# #############################################################################
# Main
# #############################################################################
data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

module "sg-va" {
  source = "./sg-va"

  environment     = data.terraform_remote_state.vpc.outputs.environment
  key_name        = data.terraform_remote_state.vpc.outputs.key_name
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets.*
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
}
