# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "public_security_group_id" {}

variable "private_security_group_id" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "key_name" {}

variable "public_key" {}

variable "private_key_path" {}

variable "ec2_profile" {}

variable "s3_bucket" {}

#
# Active Directory
#
variable "active_directory" {}

variable "windows_ad_domain_name" {}

variable "windows_ad_user_name" {}

variable "windows_ad_safe_password" {}

#
# Instance parameters Windows
#
variable "windows_username" {}

variable "windows_client_count" {}

variable "windows_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t3.medium"
}

variable "windows_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Windows Server"
  default     = "40"
}

variable "windows_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Windows Server."
  default     = "gp2"
}

variable "ami_windows_client" {
  type        = list(any)
  description = "AMI to use for instance creation."
  default     = []
}

variable "windows_server_private_ip" {}

#
# Instance parameters Apex
#
variable "create_apex_one" {}

variable "create_apex_central" {}

variable "apex_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t3.large"
}

variable "apex_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Windows Server"
  default     = "60"
}

variable "apex_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Windows Server."
  default     = "gp2"
}

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

variable "apex_central_private_ip" {}

variable "apex_one_private_ip" {}

#
# Instance parameters Exchange
#
variable "create_exchange" {}

variable "exchange_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t3.xlarge"
}

variable "exchange_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Windows Server"
  default     = "100"
}

variable "exchange_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Windows Server."
  default     = "gp2"
}

variable "ami_exchange" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "exchange_private_ip" {}

variable "transport_instance_type" {
  type        = string
  description = "EC2 instance type for Windows Server"
  default     = "t3.xlarge"
}

variable "transport_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Windows Server"
  default     = "60"
}

variable "transport_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Windows Server."
  default     = "gp2"
}

variable "ami_transport" {
  type        = string
  description = "AMI to use for instance creation."
  default     = ""
}

variable "transport_private_ip" {}
