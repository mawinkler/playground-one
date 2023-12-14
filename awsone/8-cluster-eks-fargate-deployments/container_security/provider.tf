# ####################################
# Container Security API Configuration
# ####################################
terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18.0"
      configuration_aliases = [ restapi.clusters ]
    }
  }
  required_version = ">= 1.6"
}
