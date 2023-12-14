module "vpc" {
  source = "./vpc"

  access_ip          = var.access_ip
  environment        = var.environment
  xdr_for_containers = var.xdr_for_containers
}

module "ec2" {
  source = "./ec2"

  access_ip           = var.access_ip
  environment         = var.environment
  one_path            = var.one_path
  vpc_id              = module.vpc.vpc_id
  public_subnets_cidr = module.vpc.public_subnet_cidr_blocks
}
