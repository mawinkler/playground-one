variable "environment" {}

# variable "vpc_id" {}

variable "private_subnets" {}

variable "public_subnets" {}

variable "public_security_group_id" {}

variable "key_name" {}

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

# variable "windows_ad_nebios_name" {
#   type        = string
#   description = "Active Directory NetBIOS Name"
#   default     = "ADFS"
# }

variable "windows_ad_safe_password" {
  type        = string
  description = "Active Directory DSRM Password"
}

variable "windows_ad_user_name" {
  type        = string
  description = "Username used for the local Administrator"
  default     = "Administrator"
}

variable "windows_domain_member_count" {
  type        = number
  description = "Number of domain members to add to this domain"
  default     = "2"
}
