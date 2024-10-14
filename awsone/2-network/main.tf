module "vpc" {
  source = "./vpc"

  access_ip   = var.access_ip
  environment = var.environment
  # xdr_for_containers = var.xdr_for_containers
}

module "ec2" {
  source = "./ec2"

  access_ip            = var.access_ip
  environment          = var.environment
  one_path             = var.one_path
  vpc_id               = module.vpc.vpc_id
  public_subnets_cidr  = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr = module.vpc.private_subnet_cidr_blocks
}

module "mad" {
  count = var.managed_active_directory ? 1 : 0

  source = "./mad"

  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}

module "ad" {
  count = var.active_directory ? 1 : 0

  source = "./ad"

  environment                     = var.environment
  vpc_id                          = module.vpc.vpc_id
  private_subnets                 = module.vpc.private_subnets
  public_subnets                  = module.vpc.public_subnets
  public_security_group_id        = module.ec2.public_security_group_id
  key_name                        = module.ec2.key_name
  windows_ad_domain_name          = var.ad_domain_name
  windows_ad_nebios_name          = var.ad_nebios_name
  windows_ad_user_name            = var.ad_domain_admin
  windows_ad_safe_password        = var.ad_admin_password
  virtual_network_sensor          = var.virtual_network_sensor
  vns_va_traffic_mirror_filter_id = try(module.vns[0].vns_va_traffic_mirror_filter_id, "")
  vns_va_traffic_mirror_target_id = try(module.vns[0].vns_va_traffic_mirror_target_id, "")
}

module "sg" {
  count = var.service_gateway ? 1 : 0

  source = "./sg"

  access_ip                = var.access_ip
  environment              = var.environment
  vpc_id                   = module.vpc.vpc_id
  public_security_group_id = module.ec2.public_security_group_id
  public_subnets           = module.vpc.public_subnets.*
  public_subnets_cidr      = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr     = module.vpc.private_subnet_cidr_blocks
  key_name                 = module.ec2.key_name
  public_key               = module.ec2.public_key
  private_key_path         = module.ec2.private_key_path
  instance_type            = "c5.2xlarge"
}

module "vns" {
  count = var.virtual_network_sensor ? 1 : 0

  source = "./vns"

  access_ip            = var.access_ip
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnets       = module.vpc.public_subnets.*
  public_subnets_cidr  = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr = module.vpc.private_subnet_cidr_blocks
  instance_type        = "t3.large"
  vns_token            = var.vns_token
}
