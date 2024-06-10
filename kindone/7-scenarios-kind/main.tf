data "terraform_remote_state" "kind" {
  backend = "local"

  config = {
    path = "../4-cluster-kind/terraform.tfstate"
  }
}

module "default" {
  source      = "./default"
  environment = var.environment
  namespace   = "default"
}

module "attackers" {
  source      = "./attackers"
  environment = var.environment
  namespace   = "attackers"
}
