variable "aws_region" {
  type = string
}

variable "access_ip" {
  type = list
}

variable "environment" {
  type = string
}

variable "ecs_ec2" {
  type    = bool
}

variable "ecs_fargate" {
  type    = bool
}
