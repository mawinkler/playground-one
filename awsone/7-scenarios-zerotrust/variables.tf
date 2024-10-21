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
  type = string
  sensitive = true
}

variable "access_ip" {
  type = list(any)
}

variable "environment" {
  type = string
}

# AWS PGO Active Directory
variable "active_directory" {
  type = bool
}

variable "linux_username" {
  type = string
}

variable "windows_username" {
  type = string
}

variable "create_linux" {
  type = bool
}

# Private Access Gateway
variable "private_access_gateway" {
  type = bool
}

# variable "private_access_gateway_registration_token" {
#   type = string
# }