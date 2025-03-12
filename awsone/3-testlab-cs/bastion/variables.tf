# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "public_security_group_id" {}

variable "public_subnets" {}

variable "key_name" {}

variable "private_key_path" {}

variable "ec2_profile" {}

#
# Instance parameters
#
variable "ami_bastion" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "linux_username" {}

variable "dsm_private_ip" {}
