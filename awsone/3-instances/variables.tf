# CUSTOMIZE
# Number of instances and Vision One Deployment here
variable "linux_count" {
  type    = number
  default = 2
}

variable "windows_count" {
  type    = number
  default = 0
}
# /CUSTOMIZE

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

#
# Storage
#
variable "s3_bucket" {
  type    = string
  default = "playground-awsone"
}

#
# PGO VPN Gateway
#
variable "vpn_gateway" {
  type = bool
}

#
# Active Directory
#
variable "active_directory" {
  type = bool
}

#
# Instances
#
variable "linux_username" {
  type = string
}

variable "windows_username" {
  type = string
}

#
# Vision One Endpoint Security
#
variable "agent_deploy" {
  type    = bool
  default = false
}

variable "agent_variant" {
  type = string
  # Which agent to deploy?
  # Allowed values:
  #   TMServerAgent (Server and Workload Security)
  #   TMSensorAgent (Basecamp)
  default = "TMServerAgent"
}

#
# Create Attack Path
#
variable "create_attackpath" {
  type = bool
}

variable "rds_name" {
  type = string
}

variable "rds_username" {
  type = string
}

#
# Virtual Network Ssensor
#
variable "virtual_network_sensor" {
  type    = bool
  default = false
}

#
# Deep Discovery Inspector
#
variable "deep_discovery_inspector" {
  type    = bool
  default = false
}
