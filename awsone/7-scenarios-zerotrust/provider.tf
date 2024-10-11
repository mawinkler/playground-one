# #############################################################################
# Providers
# #############################################################################
provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "ad" {
  winrm_hostname = data.terraform_remote_state.vpc.outputs.ad_dc_ip
  winrm_username = data.terraform_remote_state.vpc.outputs.ad_domain_admin
  winrm_password = data.terraform_remote_state.vpc.outputs.ad_admin_password
  winrm_use_ntlm = true
  winrm_port     = 5986
  winrm_proto    = "https"
  winrm_insecure = true
}

terraform {
  required_version = ">= 1.6"

  required_providers {
    ad = {
      source  = "hashicorp/ad"
      version = "~> 0.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
  }
}
