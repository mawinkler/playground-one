# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "public_security_group_id" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "key_name" {}

variable "public_key" {}

variable "private_key_path" {}

variable "ec2_profile" {}

variable "s3_bucket" {}

variable "vpn_gateway" {}

variable "linux_username" {}

variable "linux_hostname" {}

variable "linux_web_hostname" {}

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

variable "windows_username" {}

variable "windows_hostname" {}

variable "create_linux" {}

variable "create_windows" {}

variable "active_directory" {}

variable "windows_ad_domain_name" {}

variable "windows_ad_user_name" {}

variable "windows_ad_safe_password" {}

variable "virtual_network_sensor" {}
variable "vns_va_traffic_mirror_filter_id" {}
variable "vns_va_traffic_mirror_target_id" {}

variable "deep_discovery_inspector" {}
variable "ddi_va_traffic_mirror_filter_id" {}
variable "ddi_va_traffic_mirror_target_id" {}
