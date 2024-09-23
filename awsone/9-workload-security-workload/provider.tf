# #############################################################################
# Provider
# #############################################################################
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# ####################################
# Deep Security API Configuration
# ####################################
provider "time" {
  # Configuration options
}

provider "restapi" {
  alias                = "wsrest"
  uri                  = "https://workload.${var.ws_region}.cloudone.trendmicro.com/api"
  debug                = true
  insecure             = false
  write_returns_object = true

  headers = {
    Cache-Control = "no-cache"
    Content-Type  = "application/json"
    api-version   = "v1"
    api-secret-key = "${var.ws_apikey}"
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
