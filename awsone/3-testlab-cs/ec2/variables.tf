# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "public_security_group_id" {}

variable "public_subnets" {}

variable "key_name" {}

variable "public_key" {}

variable "private_key_path" {}

variable "ec2_profile" {}

variable "s3_bucket" {}

variable "windows_count" {}

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

variable "windows_username" {}

variable "create_windows" {}

variable "active_directory" {}

variable "windows_ad_domain_name" {}

variable "windows_ad_user_name" {}

variable "windows_ad_safe_password" {}
