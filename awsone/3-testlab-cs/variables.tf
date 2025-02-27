# CUSTOMIZE
variable "windows_count" {
  type = number
  default = 1
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

variable "s3_bucket" {
  type    = string
  default = "playground-awsone"
}

variable "windows_username" {
  type = string
}

variable "create_windows" {
  type = bool
  default = true
}

variable "environment" {
  type = string
}

#
# Active Directory
#
variable "active_directory" {
  type = bool
}
