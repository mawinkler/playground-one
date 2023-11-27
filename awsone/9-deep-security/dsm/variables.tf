# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "public_security_group_id" {}

variable "private_security_group_id" {}

variable "key_name" {}

variable "public_key" {}

variable "private_key_path" {}

variable "ec2_profile" {}

variable "s3_bucket" {}

variable "linux_username" {}

variable "vpc_id" {}

# Bastion
variable "bastion_public_ip" {}

variable "bastion_private_key" {}

# Deep Security
variable "dsm_license" {}

variable "dsm_username" {}

variable "dsm_password" {}

# Database
variable "rds_address" {}

variable "rds_name" {}

variable "rds_username" {}

variable "rds_password" {}
