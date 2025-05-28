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
  type      = string
  sensitive = true
}

variable "access_ip" {
  type = list(any)
}

variable "s3_bucket" {
  type    = string
  default = "playground-awsone"
}

variable "environment" {
  type = string
}

#
# Active Directory
#
variable "active_directory" {
  type = bool
}

#
# Instance parameters
#
variable "ami_apex_one" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "ami_apex_central" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "ami_windows_client" {
  type        = list(any)
  description = "AMI to use for instance creation."
  default     = []
}

variable "ami_exchange" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "create_apex_one" {
  type    = bool
  default = true
}

variable "create_apex_central" {
  type    = bool
  default = true
}

variable "windows_client_count" {
  type    = number
  default = 2
}

variable "create_exchange" {
  type    = bool
  default = true
}

variable "windows_username" {
  type = string
}

#
# Deep Security Instance
#
variable "create_dsm" {
  type    = bool
  default = true
}

variable "ami_bastion" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "ami_dsm" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "ami_postgresql" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

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
# Deep Security Database
#

#
# Static IPs
#
variable "dsm_private_ip" {
  type = string
}

variable "bastion_private_ip" {
  type = string
}

variable "apex_central_private_ip" {
  type = string
}

variable "apex_one_private_ip" {
  type = string
}

variable "exchange_private_ip" {
  type = string
}

variable "windows_server_private_ip" {
  type = string
}

variable "postgresql_private_ip" {
  type = string
}
