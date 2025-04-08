# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "access_ip" {}

variable "vpc_id" {}

variable "public_security_group_id" {}

variable "public_subnets" {}

variable "private_security_group_id" {}

variable "private_subnets" {}

variable "key_name" {}

# variable "vpn_gateway" {}

variable "public_key" {}

variable "private_key_path" {}

variable "public_subnets_cidr" {}

variable "private_subnets_cidr" {}

variable "instance_type" {}

variable "pgo_sg_private_ip" {}

variable "ami_service_gateway" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}
