################################################################################
# Environment
################################################################################
variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

################################################################################
# Computers
################################################################################
variable "create_linux" {
  type = bool
}

variable "create_windows" {
  type = bool
}

variable "linux_username_amzn" {
  type = string
}

variable "linux_username_ubnt" {
  type = string
}

variable "windows_username" {
  type = string
}
