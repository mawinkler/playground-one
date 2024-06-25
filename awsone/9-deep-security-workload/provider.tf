# #############################################################################
# Provider
# #############################################################################
provider "aws" {
  region = var.aws_region
}

# ####################################
# Deep Security API Configuration
# ####################################
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

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.19.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.2"
    }
  }
}
