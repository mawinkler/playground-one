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

variable "linux_username" {
  type = string
}
