# #############################################################################
# Provider
# #############################################################################
provider "aws" {
  region = var.aws_region
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  profile = "default"
}

# ####################################
# Deep Security API Configuration
# ####################################
terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18.0"
    }
  }
  required_version = ">= 1.3.5"
}

provider "restapi" {
  alias                = "dsrest"
  uri                  = "https://${module.bastion.bastion_public_ip}:4119/api"
  debug                = true
  write_returns_object = true
  insecure             = true
  use_cookies          = true

  headers = {
    Cache-Control = "no-cache"
    Content-Type  = "application/json"
    api-version   = "v1"
    Authorization = "ApiKey ${module.dsm.ds_apikey}"
  }
}
