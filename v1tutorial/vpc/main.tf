module "vpc" {
  source = "./vpc"

  access_ip   = var.access_ip
  environment = var.environment
}

module "ec2" {
  source = "./ec2"

  access_ip            = var.access_ip
  environment          = var.environment
  one_path             = var.one_path
  vpc_id               = module.vpc.vpc_id
  public_subnets_cidr  = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr = module.vpc.private_subnet_cidr_blocks
  private_subnets      = module.vpc.private_subnets.*
  private_route_tables = module.vpc.private_route_table_ids
}


module "vpn" {
  depends_on = [module.vpc.public_subnet_cidr_blocks, module.vpc.private_subnet_cidr_blocks]

  source = "./vpn"

  access_ip            = var.access_ip
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnets       = module.vpc.public_subnets.*
  public_subnets_cidr  = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr = module.vpc.private_subnet_cidr_blocks
  vpn_private_ip       = var.vpn_private_ip
}
