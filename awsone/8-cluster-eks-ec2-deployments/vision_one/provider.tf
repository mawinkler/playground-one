# ####################################
# Container Security API Configuration
# ####################################
terraform {
  required_providers {
    restapi = {
      source                = "Mastercard/restapi"
      version               = "1.20.0"
      configuration_aliases = [restapi.container_security]
    }
    visionone = {
      source                = "trendmicro/vision-one"
      version               = "~> 1.0.5"
      configuration_aliases = [visionone.container_security]
    }
  }
  required_version = ">= 1.6"
}
