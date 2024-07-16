# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "public_security_group_id" {}

variable "public_security_group_inet_id" {}

variable "public_subnets" {}

variable "key_name" {}

variable "public_key" {}

variable "private_key_path" {}

variable "ec2_profile" {}

variable "ec2_profile_db" {}

variable "s3_bucket" {}

variable "linux_username" {}

variable "linux_db_hostname" {}

variable "linux_web_hostname" {}

variable "linux_pap_hostname" {}

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

variable "linux_instance_type_pap" {
  type        = string
  description = "EC2 PAP instance type for Linux Server"
  default     = "t2.micro"
}

variable "windows_username" {}

variable "windows_hostname" {}

variable "create_linux" {}

variable "create_windows" {}

variable "create_attackpath" {}

variable "active_directory" {}

variable "windows_ad_domain_name" {}

variable "windows_ad_user_name" {}

variable "windows_ad_safe_password" {}