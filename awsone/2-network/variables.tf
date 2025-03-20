# #############################################################################
# Variables
# #############################################################################
variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "access_ip" {
  type = list(any)
}

variable "environment" {
  type = string
}

variable "one_path" {
  type = string
}

# variable "xdr_for_containers" {
#   type = bool
# }

#
# PGO VPN Gateway
#
variable "vpn_gateway" {
  type = bool
}

#
# AWS Managed Active Directory
#
variable "managed_active_directory" {
  type = bool
}

#
# AWS PGO Active Directory
#
variable "ami_active_directory_dc" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "ami_active_directory_ca" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "active_directory" {
  type = bool
}

variable "ad_domain_name" {
  type = string
}

variable "ad_domain_admin" {
  type        = string
  description = "Domain Administrator Name"
  default     = "Administrator"
}

variable "ad_admin_password" {
  type        = string
  description = "Domain Administrator Password"
  default     = "TrendMicro.1"
}

#
# Service Gateway
#
variable "service_gateway" {
  type = bool
}

#
# Virtual Network Ssensor
#
variable "virtual_network_sensor" {
  type    = bool
  default = false
}

variable "vns_token" {
  type = string
}

#
# Deep Discovery Inspector
#
variable "deep_discovery_inspector" {
  type    = bool
  default = false
}

#
# Static IPs
#
variable "pgo_dc_private_ip" {
  type = string
}

variable "pgo_ca_private_ip" {
  type = string
}

variable "vpn_private_ip" {
  type = string
}
