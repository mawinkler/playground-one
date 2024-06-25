# #############################################################################
# Providers
# #############################################################################
provider "aws" {
  region = var.aws_region
  # profile = "default"
}

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
  }
}
