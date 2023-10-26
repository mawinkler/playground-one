data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../4-cluster-eks-ec2/terraform.tfstate"
  }
}

module "victims" {
  source      = "./victims"
  aws_region  = var.aws_region
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "victims"
}

module "default" {
  source      = "./default"
  aws_region  = var.aws_region
  environment = var.environment
  namespace   = "default"
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
