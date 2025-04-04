# ####################################
# Variables
# ####################################
variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
  sensitive = true
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

variable "cluster_policy_operator" {
  type = bool
}

variable "group_id" {
  type = string
}

variable "api_key" {
  type = string
}

variable "api_url" {
  type = string
}

# Calico
variable "calico" {
  type = bool
}
