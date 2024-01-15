variable "environment" {
  type = string
}

variable "access_ip" {
  type = list
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

# variable "msi_id" {
#   type        = string
#   description = "The Managed Service Identity ID. Set this value if you're running this example using Managed Identity as the authentication method."
#   default     = null
# }

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use."
  default     = ""
}