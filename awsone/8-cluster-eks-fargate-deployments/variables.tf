# ####################################
# Variables
# ####################################
variable "aws_region" {
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

variable "environment" {
  type = string
}

# Cloud One
variable "cloud_one_region" {
  type = string
}

variable "cloud_one_instance" {
  type = string
}

variable "api_key" {
  type = string
}

# Calico
variable "calico" {
  type = bool
}
