variable "aws_region" {
  type = string
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

#
# create attack path
#
variable "create_attackpath" {
  type = bool
}

# MAD
variable "active_directory" {
  type = bool
}

# Service Gateway
variable "service_gateway" {
  type = bool
}
