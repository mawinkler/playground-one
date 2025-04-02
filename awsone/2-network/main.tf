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
  private_subnets      = module.vpc.private_subnets.*
  private_route_tables = module.vpc.private_route_table_ids
}

module "vpn" {
  depends_on = [module.vpc.public_subnet_cidr_blocks, module.vpc.private_subnet_cidr_blocks]

  count = var.vpn_gateway ? 1 : 0

  source = "./vpn"

  access_ip            = var.access_ip
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnets       = module.vpc.public_subnets.*
  public_subnets_cidr  = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr = module.vpc.private_subnet_cidr_blocks
  vpn_private_ip       = var.vpn_private_ip
}

# module "vpn-awsclient" {
#   source = "./vpn-awsclient"

#   environment     = var.environment
#   vpc_id          = module.vpc.vpc_id
#   private_subnets = module.vpc.private_subnets
#   public_subnets  = module.vpc.public_subnets
# }

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

  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnets            = module.vpc.public_subnets
  private_subnets           = module.vpc.private_subnets
  public_security_group_id  = module.ec2.public_security_group_id
  private_security_group_id = module.ec2.private_security_group_id
  key_name                  = module.ec2.key_name
  public_key                = module.ec2.public_key
  windows_username          = var.windows_username
  vpn_gateway               = var.vpn_gateway
  windows_ad_domain_name    = var.ad_domain_name
  windows_ad_nebios_name    = upper(var.environment)
  windows_ad_user_name      = var.ad_domain_admin
  windows_ad_safe_password  = var.ad_admin_password
  pgo_dc_private_ip         = var.pgo_dc_private_ip
  pgo_ca_private_ip         = var.pgo_ca_private_ip

  ami_active_directory_dc = try(var.ami_active_directory_dc, "")
  ami_active_directory_ca = try(var.ami_active_directory_ca, "")

  virtual_network_sensor          = var.virtual_network_sensor
  vns_va_traffic_mirror_filter_id = try(module.vns[0].vns_va_traffic_mirror_filter_id, "")
  vns_va_traffic_mirror_target_id = try(module.vns[0].vns_va_traffic_mirror_target_id, "")
}

module "sg" {
  count = var.service_gateway ? 1 : 0

  source = "./sg"

  access_ip                 = var.access_ip
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_security_group_id  = module.ec2.public_security_group_id
  private_security_group_id = module.ec2.private_security_group_id
  public_subnets            = module.vpc.public_subnets.*
  private_subnets           = module.vpc.private_subnets.*
  public_subnets_cidr       = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr      = module.vpc.private_subnet_cidr_blocks
  key_name                  = module.ec2.key_name
  vpn_gateway               = var.vpn_gateway
  public_key                = module.ec2.public_key
  private_key_path          = module.ec2.private_key_path
  instance_type             = "c5.2xlarge"
  pgo_sg_private_ip         = var.pgo_sg_private_ip

  ami_service_gateway = try(var.ami_service_gateway, "")
}

module "vns" {
  count = var.virtual_network_sensor ? 1 : 0

  source = "./vns"

  access_ip            = var.access_ip
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  public_subnets       = module.vpc.public_subnets.*
  private_subnets      = module.vpc.private_subnets.*
  public_subnets_cidr  = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr = module.vpc.private_subnet_cidr_blocks
  instance_type        = "t3.large"
  vns_token            = var.vns_token
  vpn_gateway          = var.vpn_gateway
  pgo_vns_private_ip   = var.pgo_ddi_private_ip
  pgo_vns_subnet_no    = 1
}

module "ddi" {
  count = var.deep_discovery_inspector ? 1 : 0

  source = "./ddi"

  access_ip                = var.access_ip
  environment              = var.environment
  vpc_id                   = module.vpc.vpc_id
  public_security_group_id = module.ec2.public_security_group_id
  public_subnets           = module.vpc.public_subnets.*
  private_subnets          = module.vpc.private_subnets.*
  public_subnets_cidr      = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr     = module.vpc.private_subnet_cidr_blocks
  key_name                 = module.ec2.key_name
  vpn_gateway              = var.vpn_gateway
  public_key               = module.ec2.public_key
  private_key_path         = module.ec2.private_key_path
  instance_type            = "m5a.2xlarge"
  pgo_ddi_private_ip       = var.pgo_ddi_private_ip
  pgo_ddi_subnet_no        = 1

  ami_deep_discovery_inspector = try(var.ami_deep_discovery_inspector, "")
}
