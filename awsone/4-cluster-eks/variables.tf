variable "account_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "access_ip" {
  type = list
}

variable "environment" {
  type = string
}

variable "create_fargate_profile" {
  type = bool
}
