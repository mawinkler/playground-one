data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../2-network/terraform.tfstate"
  }
}

module "ec2" {
  source = "./ec2"

  environment                       = var.environment
  public_security_group_id          = data.terraform_remote_state.vpc.outputs.public_security_group_id
  public_subnets                    = data.terraform_remote_state.vpc.outputs.public_subnets.*
  private_security_group_id         = data.terraform_remote_state.vpc.outputs.private_security_group_id
  private_subnets                   = data.terraform_remote_state.vpc.outputs.private_subnets.*
  key_name                          = data.terraform_remote_state.vpc.outputs.key_name
  public_key                        = data.terraform_remote_state.vpc.outputs.public_key
  private_key_path                  = data.terraform_remote_state.vpc.outputs.private_key_path
  ec2_profile                       = module.iam.ec2_profile
  s3_bucket                         = data.terraform_remote_state.vpc.outputs.s3_bucket
  vpn_gateway                       = var.vpn_gateway
  linux_username                    = var.linux_username
  windows_username                  = var.windows_username
  windows_hostname                  = "Windows-Server"
  linux_hostname                    = "linuxsrv"
  linux_count                       = var.linux_count
  windows_count                     = var.windows_count
  agent_deploy                      = var.agent_deploy
  agent_variant                     = var.agent_variant
  ssm_document_sensor_agent_linux   = data.terraform_remote_state.vpc.outputs.ssm_document_sensor_agent_linux
  ssm_document_server_agent_linux   = data.terraform_remote_state.vpc.outputs.ssm_document_server_agent_linux
  ssm_document_sensor_agent_windows = data.terraform_remote_state.vpc.outputs.ssm_document_sensor_agent_windows
  ssm_document_server_agent_windows = data.terraform_remote_state.vpc.outputs.ssm_document_server_agent_windows

  # PGO Active Directory
  active_directory         = var.active_directory
  windows_ad_domain_name   = try(data.terraform_remote_state.vpc.outputs.ad_domain_name, "")
  windows_ad_user_name     = try(data.terraform_remote_state.vpc.outputs.ad_domain_admin, "")
  windows_ad_safe_password = try(data.terraform_remote_state.vpc.outputs.ad_admin_password, "")

  # VNS
  virtual_network_sensor          = var.virtual_network_sensor
  vns_va_traffic_mirror_filter_id = try(data.terraform_remote_state.vpc.outputs.vns_va_traffic_mirror_filter_id, "")
  vns_va_traffic_mirror_target_id = var.vpn_gateway ? try(data.terraform_remote_state.vpc.outputs.vns_va_traffic_mirror_target_private_id, "") : try(data.terraform_remote_state.vpc.outputs.vns_va_traffic_mirror_target_public_id, "")

  # DDI
  deep_discovery_inspector        = var.deep_discovery_inspector
  ddi_va_traffic_mirror_filter_id = try(data.terraform_remote_state.vpc.outputs.ddi_va_traffic_mirror_filter_id, "")
  ddi_va_traffic_mirror_target_id = var.vpn_gateway ? try(data.terraform_remote_state.vpc.outputs.ddi_va_traffic_mirror_target_private_id, "") : try(data.terraform_remote_state.vpc.outputs.ddi_va_traffic_mirror_target_public_id, "")
}

module "iam" {
  source = "./iam"

  environment = var.environment
  aws_region  = var.aws_region
  s3_bucket   = data.terraform_remote_state.vpc.outputs.s3_bucket
  # ssm_key     = data.terraform_remote_state.vpc.outputs.ssm_key
}

# module "s3" {
#   source = "./s3"

#   environment = var.environment
# }

# ASRM Predictive Attack Path Analysis
module "pap" {
  count = var.create_attackpath ? 1 : 0

  source = "./pap"

  environment               = var.environment
  vpc_id                    = data.terraform_remote_state.vpc.outputs.vpc_id
  access_ip                 = var.access_ip
  key_name                  = data.terraform_remote_state.vpc.outputs.key_name
  private_key_path          = data.terraform_remote_state.vpc.outputs.private_key_path
  public_subnets            = data.terraform_remote_state.vpc.outputs.public_subnets.*
  public_subnets_cidr       = data.terraform_remote_state.vpc.outputs.public_subnet_cidr_blocks
  private_subnets_cidr      = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
  private_security_group_id = data.terraform_remote_state.vpc.outputs.private_security_group_id
  database_subnet_group     = data.terraform_remote_state.vpc.outputs.database_subnet_group
  s3_bucket                 = data.terraform_remote_state.vpc.outputs.s3_bucket
  linux_username            = var.linux_username
  linux_pap_hostname        = "linuxpap"
  rds_name                  = var.rds_name
  rds_username              = var.rds_username
}
