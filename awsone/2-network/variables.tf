variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
  sensitive = true
}

variable "access_ip" {
  type = list(any)
}

variable "environment" {
  type = string
}

variable "one_path" {
  type = string
}

# variable "xdr_for_containers" {
#   type = bool
# }

# AWS Managed Active Directory
variable "managed_active_directory" {
  type = bool
}

# AWS PGO Active Directory
variable "active_directory" {
  type = bool
}

variable "ad_domain_name" {
  type = string
}

variable "ad_nebios_name" {
  type = string
}

variable "ad_domain_admin" {
  type        = string
  description = "Domain Administrator Name"
  default     = "Administrator"
}

variable "ad_admin_password" {
  type        = string
  description = "Domain Administrator Password"
  default     = "TrendMicro.1"
}

# Service Gateway
variable "service_gateway" {
  type = bool
}
