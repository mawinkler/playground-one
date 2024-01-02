variable "aws_region" {
  type = string
}

variable "s3_bucket" {
  type    = string
  default = "playground-awsone"
}

variable "linux_username" {
  type = string
}

variable "windows_username" {
  type = string
}

variable "create_linux" {
  type = bool
}

variable "create_windows" {
  type = bool
}

variable "create_database" {
  type = bool
}

variable "environment" {
  type = string
}

#
# db1 Database
#
variable "rds_name" {
  type = string
}

variable "rds_username" {
  type = string
}
