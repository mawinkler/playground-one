module "vpc" {
  source               = "./vpc"
  access_ip            = var.access_ip
  environment          = var.environment
  vpc_cidr             = local.vpc_cidr
  public_subnets_cidr  = local.public_subnets_cidr
  private_subnets_cidr = local.private_subnets_cidr
  xdr_for_containers   = var.xdr_for_containers
}

module "ec2" {
  source          = "./ec2"
  environment     = var.environment
  one_path        = var.one_path
  vpc_id          = module.vpc.vpc_id
  security_groups = local.security_groups
}
