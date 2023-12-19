# ####################################
# Variables
# ####################################
variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "access_ip" {
  type = string
}

# Container Security
variable "container_security" {
  type = bool
}

variable "cluster_policy" {
  type = string
}

variable "api_key" {
  type = string
}

# Calico
variable "calico" {
  type = bool
}
