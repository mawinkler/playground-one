variable "environment" {}

variable "vpc_id" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "public_security_group_id" {}

variable "private_security_group_id" {}

variable "key_name" {}

variable "vpn_gateway" {}

variable "windows_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t3.medium"
}

variable "windows_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Windows Server"
  default     = "30"
}

variable "windows_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Windows Server."
  default     = "gp2"
}

variable "windows_ad_domain_name" {
  type        = string
  description = "Active Directory Domain Name"
}

variable "windows_ad_nebios_name" {
  type        = string
  description = "Active Directory NetBIOS Name"
  default     = "ADFS"
}

variable "windows_ad_safe_password" {
  type        = string
  description = "Active Directory DSRM Password"
}

variable "windows_ad_user_name" {
  type        = string
  description = "Username used for the local Administrator"
  default     = "Administrator"
}


variable "ami_active_directory_dc" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "ami_active_directory_ca" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "virtual_network_sensor" {}

variable "vns_va_traffic_mirror_filter_id" {}

variable "vns_va_traffic_mirror_target_id" {}
