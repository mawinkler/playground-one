data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "s3" {
  source      = "./s3"
  environment = var.environment
}
