# #############################################################################
# Variables
# #############################################################################
variable "access_ip" {}

variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "environment" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "node_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}

variable "node_os_sku" {
  type        = string
  default     = "Ubuntu"
  description = "Specifies the OS SKU used by the agent pool."
}

variable "username" {
  type        = string
  description = "The admin username for the new cluster."
  default     = "azureadmin"
}

variable "network_plugin" {
  default = "azure"
  # default = "kubenet"
  # default = "flannel"
  # default = "cilium"
}

variable "network_policy" {
  type        = string
  description = "Azure Network Policy"
  default     = "azure"
}

#####

variable "network_address_space" {
  type        = string
  default     = "192.168.0.0/16"
  description = "Azure VNET Address Space"
}

variable "aks_subnet_address_name" {
  type        = string
  default     = "aks"
  description = "AKS Subnet Address Name"
}

variable "aks_subnet_address_prefix" {
  type        = string
  default     = "192.168.0.0/24"
  description = "AKS Subnet Address Space"
}

variable "subnet_address_name" {
  type        = string
  default     = "appgw"
  description = "Subnet Address Name"
}

variable "subnet_address_prefix" {
  type        = string
  default     = "192.168.1.0/24"
  description = "Subnet Address Space"
}
