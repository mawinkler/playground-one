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

variable "environment" {
  type = string
}

# AWS PGO Active Directory
variable "active_directory" {
  type = bool
}
