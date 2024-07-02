module "vpc" {
  source = "./vpc"

  access_ip   = var.access_ip
  environment = var.environment
  px          = var.px
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

module "rds" {
  source = "./rds"

  environment               = var.environment
  private_security_group_id = module.ec2.private_security_group_id
  database_subnet_group     = module.vpc.database_subnet_group
  rds_name                  = var.rds_name
  rds_username              = var.rds_username
}

module "bastion" {
  source = "./bastion"

  environment              = var.environment
  public_security_group_id = module.ec2.public_security_group_id
  public_subnets           = module.vpc.public_subnets.*
  key_name                 = module.ec2.key_name
  private_key_path         = module.ec2.private_key_path
  ec2_profile              = module.iam.ec2_profile
  linux_username           = "ubuntu"
}

module "dsm" {
  source = "./dsm"

  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnets            = module.vpc.public_subnets.*
  private_subnets           = module.vpc.private_subnets.*
  public_security_group_id  = module.ec2.public_security_group_id
  private_security_group_id = module.ec2.private_security_group_id
  key_name                  = module.ec2.key_name
  public_key                = module.ec2.public_key
  private_key_path          = module.ec2.private_key_path
  ec2_profile               = module.iam.ec2_profile
  s3_bucket                 = module.s3.s3_bucket
  linux_username            = var.linux_username

  dsm_license  = var.dsm_license
  dsm_username = var.dsm_username
  dsm_password = var.dsm_password

  rds_address  = module.rds.rds_address
  rds_name     = var.rds_name
  rds_username = var.rds_username
  rds_password = module.rds.rds_password

  bastion_public_ip   = module.bastion.bastion_public_ip
  bastion_private_key = module.ec2.private_key
}

module "iam" {
  source      = "./iam"
  environment = var.environment
  s3_bucket   = module.s3.s3_bucket
}

module "s3" {
  source      = "./s3"
  environment = var.environment
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
