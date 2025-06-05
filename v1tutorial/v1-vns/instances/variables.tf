# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "vpc_id" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "public_subnets_cidr" {}

variable "private_subnets_cidr" {}

variable "private_security_group_id" {}

variable "key_name" {}

variable "public_key" {}

variable "linux_username" {
  default = "ubuntu"
}

variable "linux_hostname" {
  default = "linux"
}

variable "windows_username" {
  default = "administrator"
}

variable "windows_hostname" {
  default = "windows"
}

variable "linux_count" {
  default = 1
}

variable "windows_count" {
  default = 3
}

variable "windows_ad_safe_password" {
  default = "TrendMicro.1"
}

variable "vns_va_traffic_mirror_filter_id" {}

variable "vns_va_traffic_mirror_target_id" {}
