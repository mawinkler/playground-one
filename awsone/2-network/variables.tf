variable "aws_region" {
  type = string
}

variable "access_ip" {
  type = list
}

variable "environment" {
  type    = string
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
