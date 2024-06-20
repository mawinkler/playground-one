variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

# AWS Managed Active Directory
variable "managed_active_directory" {
  type = bool
}

# AWS PGO Active Directory
variable "active_directory" {
  type = bool
}
