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

variable "public_key" {}

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

variable "linux_username_amzn" {}

variable "linux_username_ubnt" {}

variable "linux_username_rhel" {}

variable "windows_username" {}

variable "linux_policy_id" {}

variable "windows_policy_id" {}

#
# Bastion
#
variable "bastion_private_ip" {}
