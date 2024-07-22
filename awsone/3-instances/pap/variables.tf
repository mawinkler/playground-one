# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "access_ip" {}

variable "vpc_id" {}

variable "key_name" {}

variable "private_key_path" {}

variable "public_subnets" {}

variable "public_subnets_cidr" {}

variable "private_subnets_cidr" {}

variable "s3_bucket" {}

# Instance
variable "linux_username" {}

variable "linux_pap_hostname" {}

variable "linux_instance_type_pap" {
  type        = string
  description = "EC2 PAP instance type for Linux Server"
  default     = "t3.micro"
}

# RDS
variable "private_security_group_id" {}

variable "database_subnet_group" {}

variable "rds_name" {}

variable "rds_username" {}
