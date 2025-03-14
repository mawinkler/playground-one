# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "vpc_id" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "public_security_group_id" {}

variable "private_security_group_id" {}

variable "key_name" {}

variable "public_key" {}

variable "private_key_path" {}

variable "ec2_profile" {}

variable "s3_bucket" {}

#
# Instance parameters
#
variable "linux_username" {}

variable "ami_dsm" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "dsm_license" {}

variable "dsm_username" {}

variable "dsm_password" {}

variable "dsm_private_ip" {}

#
# Bastion
#
variable "bastion_public_ip" {}

variable "bastion_private_ip" {}

variable "bastion_private_key" {}

#
# Database
#
variable "rds_address" {}

variable "rds_name" {}

variable "rds_username" {}

variable "rds_password" {}
