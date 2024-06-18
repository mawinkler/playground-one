# #############################################################################
# Providers
# #############################################################################
provider "aws" {
  region  = var.aws_region
  # profile = "default"
}

terraform {
  required_version = ">= 1.6"
}

# provider "ad" {
#   winrm_hostname = "10.0.0.37"
#   winrm_username = "admin"
#   winrm_password = module.ad.mad_admin_password
# }
