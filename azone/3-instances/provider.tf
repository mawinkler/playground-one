# #############################################################################
# Providers
# #############################################################################
provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.6"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.2"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

