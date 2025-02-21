module "vpc" {
  source = "./vpc"

  access_ip   = var.access_ip
  environment = var.environment
}

module "iam" {
  source = "./iam"

  environment = var.environment
  aws_region  = var.aws_region
  s3_bucket   = module.s3.s3_bucket
}

module "s3" {
  source = "./s3"

  environment = var.environment
}

module "ec2" {
  source = "./ec2"

  access_ip            = var.access_ip
  environment          = var.environment
  one_path             = var.one_path
  vpc_id               = module.vpc.vpc_id
  public_subnets       = module.vpc.public_subnets
  public_subnets_cidr  = module.vpc.public_subnet_cidr_blocks
  private_subnets_cidr = module.vpc.private_subnet_cidr_blocks
  private_subnets      = module.vpc.private_subnets.*
  private_route_tables = module.vpc.private_route_table_ids

  create_linux   = var.create_linux
  ec2_profile    = module.iam.ec2_profile
  s3_bucket      = module.s3.s3_bucket
  linux_username = var.linux_username
  agent_deploy   = var.agent_deploy
  agent_variant  = var.agent_variant
}
