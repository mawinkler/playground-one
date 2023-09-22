data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../4-cluster-eks/terraform.tfstate"
  }
}

module "victims" {
  source      = "./victims"
  aws_region  = var.aws_region
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "victims"
}

module "fargate" {
  source      = "./fargate"
  aws_region  = var.aws_region
  environment = var.environment
  namespace   = "fargate"
}

module "goat" {
  source      = "./goat"
  aws_region  = var.aws_region
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "goat"
}

module "attackers" {
  source      = "./attackers"
  aws_region  = var.aws_region
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "attackers"
}
