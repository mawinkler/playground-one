data "terraform_remote_state" "aks" {
  backend = "local"

  config = {
    path = "../4-cluster-aks/terraform.tfstate"
  }
}

module "victims" {
  source      = "./victims"
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "victims"
}

module "default" {
  source      = "./default"
  environment = var.environment
  namespace   = "default"
}

module "goat" {
  source      = "./goat"
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "goat"
}

module "attackers" {
  source      = "./attackers"
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "attackers"
}
