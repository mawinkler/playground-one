# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

#
# VPC
#
variable "public_subnets" {}

variable "public_security_group_id" {}

#
# Key
#
variable "key_name" {}

variable "private_key_path" {}

#
# IAM
#
variable "ec2_profile" {}

#
# S3
#
variable "s3_bucket" {}

#
# EC2
#
variable "create_linux" {}

variable "create_windows" {}

variable "linux_username" {}

#
# Bastion
#
variable "bastion_private_ip" {}
