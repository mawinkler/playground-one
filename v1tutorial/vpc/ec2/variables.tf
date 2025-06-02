# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "one_path" {}

variable "vpc_id" {}

variable "public_subnets_cidr" {}

variable "private_subnets_cidr" {}

variable "private_subnets" {}

variable "private_subnet" {
  type    = bool
  default = false
}

variable "private_route_tables" {}
