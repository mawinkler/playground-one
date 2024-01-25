# ####################################
# Variables
# ####################################
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

variable "api_key" {
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
