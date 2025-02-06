# ####################################
# Variables
# ####################################
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

# MetalLB
variable "metallb" {
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

variable "pgoweb" {
  type = bool
}

# ArgoCD
variable "argocd" {
  type = bool
}

variable "argocd_admin_secret" {
  type = string
}
