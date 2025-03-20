data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ec2" {
  source = "./ec2"

  environment               = var.environment
  public_security_group_id  = data.terraform_remote_state.vpc.outputs.public_security_group_id
  public_subnets            = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_subnets.*
  key_name                  = data.terraform_remote_state.vpc.outputs.key_name
  public_key                = data.terraform_remote_state.vpc.outputs.public_key
  private_key_path          = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile               = module.iam.ec2_profile
  s3_bucket                 = module.s3.s3_bucket
  windows_username          = var.windows_username
  create_apex_one_server    = var.create_apex_one_server
  create_apex_one_central   = var.create_apex_one_central
  windows_client_count      = var.windows_client_count
  apex_central_private_ip   = var.apex_central_private_ip
  apex_one_private_ip       = var.apex_one_private_ip
  windows_server_private_ip = var.windows_server_private_ip

  ami_apex_one_server  = try(var.ami_apex_one_server, "")
  ami_apex_one_central = try(var.ami_apex_one_central, "")
  ami_windows_client   = try(var.ami_windows_client, [])

  # PGO Active Directory
  active_directory         = var.active_directory
  windows_ad_domain_name   = try(data.terraform_remote_state.vpc.outputs.ad_domain_name, "")
  windows_ad_user_name     = try(data.terraform_remote_state.vpc.outputs.ad_domain_admin, "")
  windows_ad_safe_password = try(data.terraform_remote_state.vpc.outputs.ad_admin_password, "")
}

module "iam" {
  source = "./iam"

  environment = var.environment
  aws_region  = var.aws_region
  s3_bucket   = module.s3.s3_bucket
  # ssm_key     = data.terraform_remote_state.vpc.outputs.ssm_key
}

module "s3" {
  source = "./s3"

  environment = var.environment
}

#
# Deep Security
#
module "rds" {
  # count = var.create_dsm ? 1 : 0
  count = var.create_dsm ? 0 : 0

  source = "./rds"

  environment               = var.environment
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
  database_subnet_group     = data.terraform_remote_state.vpc.outputs.database_subnet_group
  rds_name                  = var.rds_name
  rds_username              = var.rds_username
}

module "psql" {
  count = var.create_dsm ? 1 : 0

  source = "./psql"

  environment               = var.environment
  key_name                  = data.terraform_remote_state.vpc.outputs.key_name
  ec2_profile               = module.iam.ec2_profile
  public_key                = data.terraform_remote_state.vpc.outputs.public_key
  private_key_path          = data.terraform_remote_state.vpc.outputs.private_key_path
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_subnets.*
  linux_username            = "ubuntu"
  psql_name                 = var.rds_name
  psql_username             = var.rds_username
  psql_password             = "TrendMicro.1"
  postgresql_private_ip     = var.postgresql_private_ip

  ami_postgresql = try(var.ami_postgresql, "")

  bastion_public_ip   = module.bastion[0].bastion_public_ip
  bastion_private_ip  = module.bastion[0].bastion_private_ip
  bastion_private_key = data.terraform_remote_state.vpc.outputs.private_key
}

module "bastion" {
  count = var.create_dsm ? 1 : 0

  source = "./bastion"

  environment              = var.environment
  public_security_group_id = data.terraform_remote_state.vpc.outputs.public_security_group_id
  public_subnets           = data.terraform_remote_state.vpc.outputs.public_subnets.*
  key_name                 = data.terraform_remote_state.vpc.outputs.key_name
  private_key_path         = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile              = module.iam.ec2_profile
  linux_username           = "ubuntu"
  bastion_private_ip       = var.bastion_private_ip
  dsm_private_ip           = var.dsm_private_ip

  ami_bastion = try(var.ami_bastion, "")
}

module "dsm" {
  count = var.create_dsm ? 1 : 0
  # count = var.create_dsm ? 0 : 0

  source = "./dsm"

  environment               = var.environment
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets            = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_subnets           = data.terraform_remote_state.vpc.outputs.private_subnets.*
  public_security_group_id  = data.terraform_remote_state.vpc.outputs.public_security_group_id
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
  key_name                  = data.terraform_remote_state.vpc.outputs.key_name
  public_key                = data.terraform_remote_state.vpc.outputs.public_key
  private_key_path          = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile               = module.iam.ec2_profile
  dsm_private_ip            = var.dsm_private_ip
  s3_bucket                 = module.s3.s3_bucket
  linux_username            = var.linux_username

  ami_dsm = try(var.ami_dsm, "")

  dsm_license  = var.dsm_license
  dsm_username = var.dsm_username
  dsm_password = var.dsm_password

  rds_address  = try(module.psql[0].postgres_private_ip, module.rds[0].rds_address)
  rds_name     = var.rds_name
  rds_username = var.rds_username
  # rds_password = module.rds[0].rds_password
  rds_password = try(module.psql[0].postgres_password, module.rds[0].rds_password)

  bastion_public_ip   = module.bastion[0].bastion_public_ip
  bastion_private_ip  = module.bastion[0].bastion_private_ip
  bastion_private_key = data.terraform_remote_state.vpc.outputs.private_key
}
