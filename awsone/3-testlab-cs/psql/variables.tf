# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "private_subnets" {}

variable "private_security_group_id" {}

variable "key_name" {}

variable "public_key" {}

variable "private_key_path" {}

variable "ec2_profile" {}

#
# Instance parameters
#
variable "linux_username" {}

variable "ami_postgresql" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "psql_name" {}

variable "psql_username" {}

variable "psql_password" {}

#
# Bastion
#
variable "bastion_public_ip" {}

variable "bastion_private_ip" {}

variable "bastion_private_key" {}

variable "postgresql_private_ip" {}
