# #############################################################################
# Providers
# #############################################################################
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

terraform {
  required_version = ">=1.0"

  required_providers {
    # azapi = {
    #   source  = "Azure/azapi"
    #   # version = "~>1.5"
    # }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}
