# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "public_subnets" {}

variable "private_subnets" {}

# variable "public_security_group_id" {}

variable "private_security_group_id" {}

variable "key_name" {}

variable "public_key" {}


variable "private_key_path" {}

variable "s3_bucket" {}

variable "linux_username" {
  type    = string
  default = "ubuntu"
}

variable "linux_hostname" {
  type    = string
  default = "linuxsrv"
}

variable "linux_count" {}

variable "windows_count" {}

variable "agent_deploy" {}

variable "agent_variant" {}

variable "windows_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t3.medium"
}

variable "linux_instance_type" {
  type        = string
  description = "EC2 instance type for Linux Server"
  default     = "t3.medium"
}

variable "windows_username" {
  type    = string
  default = "Administrator"
}

variable "windows_hostname" {
  type    = string
  default = "Windows-Server"
}

variable "windows_ad_user_name" {}

variable "windows_ad_safe_password" {}
