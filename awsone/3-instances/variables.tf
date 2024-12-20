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

variable "s3_bucket" {
  type    = string
  default = "playground-awsone"
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

variable "create_windows" {
  type = bool
}

variable "environment" {
  type = string
}

#
# linux-db Database
#
variable "rds_name" {
  type = string
}

variable "rds_username" {
  type = string
}

#
# Create Attack Path
#
variable "create_attackpath" {
  type = bool
}

#
# Active Directory
#
variable "active_directory" {
  type = bool
}

# Virtual Network Ssensor
variable "virtual_network_sensor" {
  type    = bool
  default = false
}

# Deep Discovery Inspector
variable "deep_discovery_inspector" {
  type    = bool
  default = false
}
