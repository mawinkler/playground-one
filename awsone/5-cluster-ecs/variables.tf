variable "aws_region" {
  type = string
}

variable "access_ip" {
  type = list
}

variable "account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ws_tenantid" {
  type    = string
  default = ""
}

variable "ws_token" {
  type    = string
  default = ""
}

variable "ws_policyid" {
  type    = number
}

variable "ecs_ec2" {
  type    = bool
}

variable "ecs_fargate" {
  type    = bool
}
