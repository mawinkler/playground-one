# ####################################
# Container Security API Configuration
# ####################################
terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.19.1"
      configuration_aliases = [ restapi.dsrest ]
    }
  }
  required_version = ">= 1.6"
}
