data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../4-cluster-eks-fargate/terraform.tfstate"
  }
}

module "default" {
  source      = "./default"
  aws_region  = var.aws_region
  environment = var.environment
  namespace   = "default"
}

module "attackers" {
  source      = "./attackers"
  aws_region  = var.aws_region
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "attackers"
}
