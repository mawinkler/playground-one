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
  type      = string
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

variable "registration_key" {
  type = string
}

# Calico
variable "calico" {
  type = bool
}

# Trivy
variable "trivy" {
  type = bool
}

# Prometheus & Grafana
variable "prometheus" {
  type = bool
}

variable "grafana_admin_password" {
  type = string
}

# Istio
variable "istio" {
  type = bool
}

variable "pgoweb" {
  type = bool
}
