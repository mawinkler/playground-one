module "vpc" {
  source               = "./vpc"
  environment          = var.environment
  vpc_cidr             = local.vpc_cidr
}
