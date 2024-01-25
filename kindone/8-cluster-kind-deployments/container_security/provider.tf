# ####################################
# Container Security API Configuration
# ####################################
terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18.2"
      configuration_aliases = [ restapi.container_security ]
    }
  }
  required_version = ">= 1.6"
}
