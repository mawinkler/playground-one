# #############################################################################
# Providers
# #############################################################################
provider "aws" {
  region  = var.aws_region
  # profile = "default"

  # ignore_tags {
  #   key_prefixes = ["ExceptionId"]
  # }
  # default_tags {
  #   tags = {
  #     ExceptionId = "1234567890"
  #   }
  # }
}

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
  }
}
