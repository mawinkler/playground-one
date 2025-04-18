################################################################################
# Environment
################################################################################
variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "environment" {
  type = string
}

################################################################################
# Workload Security
################################################################################
variable "ws_region" {
  type = string
}

variable "ws_tenant_id" {
  type = string
}

variable "ws_token" {
  type = string
}

variable "ws_apikey" {
  type = string
}

################################################################################
# Computers
################################################################################
variable "create_linux" {
  type    = bool
  default = true
}

variable "create_windows" {
  type    = bool
  default = true
}

variable "linux_username_amzn" {
  type = string
}

variable "linux_username_ubnt" {
  type = string
}

variable "windows_username" {
  type = string
}
