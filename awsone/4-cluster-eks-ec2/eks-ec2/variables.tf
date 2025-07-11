# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "vpc_id" {}

variable "vpc_owner_id" {}

variable "aws_region" {}

variable "access_ip" {}

variable "key_name" {}

variable "private_subnets" {}

variable "intra_subnets" {}

variable "private_security_group_id" {}

variable "public_security_group_id" {}

variable "vpn_server_security_group_id" {}

# Autoscaler
variable "autoscaler_enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "autoscaler_additional_settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}
