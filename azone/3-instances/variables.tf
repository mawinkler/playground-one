# ####################################
# Variables
# ####################################
variable "subscription_id" {
  type        = string
  description = "The subscription ID to use."
  default     = ""
}

variable "environment" {
  type = string
}

# variable "s3_bucket" {
#   type    = string
#   default = "playground-awsone"
# }

variable "resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureadmin"
}


# variable "linux_username" {
#   type = string
# }

# variable "windows_username" {
#   type = string
# }

variable "create_linux" {
  type = bool
}

variable "create_windows" {
  type = bool
}

#
# create attack path
#
# variable "create_attackpath" {
#   type = bool
# }
