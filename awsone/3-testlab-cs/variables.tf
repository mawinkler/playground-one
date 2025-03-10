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
variable "ami_apex_one_server" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "ami_apex_one_central" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "ami_windows_client" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "create_apex_one_server" {
  type    = bool
  default = true
}

variable "create_apex_one_central" {
  type    = bool
  default = true
}

variable "windows_client_count" {
  type    = number
  default = 2
}

variable "windows_username" {
  type = string
}
