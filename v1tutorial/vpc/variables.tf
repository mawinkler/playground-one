# #############################################################################
# Variables
# #############################################################################
variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "one_path" {
  type = string
}

#
# Virtual Network Ssensor
#
variable "virtual_network_sensor" {
  type    = bool
  default = false
}

variable "vpn_private_ip" {
  type = string
}
