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

variable "access_ip" {
  type = list(any)
}

variable "resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}
