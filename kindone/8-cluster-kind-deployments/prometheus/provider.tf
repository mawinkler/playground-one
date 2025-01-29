# ####################################
# Providers
# ####################################
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
  }
  required_version = ">= 1.6"
}
