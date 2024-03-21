################################################################################
# Environment
################################################################################
variable "aws_region" {
  type = string
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

#
# Deep Security Instance
#
variable "linux_username" {
  type = string
}

variable "dsm_license" {
  type = string
}

variable "dsm_username" {
  type = string
}

variable "dsm_password" {
  type = string
}

#
# Deep Security Database
#
variable "rds_name" {
  type = string
}

variable "rds_username" {
  type = string
}

#
# Use PX License Server
#
variable "px" {
  type = bool
}
