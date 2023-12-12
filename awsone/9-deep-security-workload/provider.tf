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
    time = {
      source  = "hashicorp/time"
      version = "0.10.0"
    }
  }
  required_version = ">= 1.3.5"
}

provider "time" {
  # Configuration options
}

provider "restapi" {
  alias                = "dsrest"
  uri                  = "https://${data.terraform_remote_state.deep_security.outputs.bastion_public_ip}:4119/api"
  debug                = true
  insecure             = true
  write_returns_object = true

  headers = {
    Cache-Control  = "no-cache"
    Content-Type   = "application/json"
    api-version    = "v1"
    api-secret-key = data.terraform_remote_state.deep_security.outputs.ds_apikey
  }
}
