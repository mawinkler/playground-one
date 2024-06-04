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
}
