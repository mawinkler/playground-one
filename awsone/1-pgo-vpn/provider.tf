# #############################################################################
# Providers
# #############################################################################
provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
