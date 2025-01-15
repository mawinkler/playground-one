################################################################################
# Environment
################################################################################
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

variable "environment" {
  type = string
}

################################################################################
# Computers
################################################################################
variable "create_linux" {
  type    = bool
  default = true
}

variable "create_windows" {
  type    = bool
  default = true
}

variable "linux_username_amzn" {
  type = string
}

variable "linux_username_ubnt" {
  type = string
}

variable "linux_username_rhel" {
  type = string
}

variable "windows_username" {
  type = string
}
