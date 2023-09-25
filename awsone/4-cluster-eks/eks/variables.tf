# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "vpc_id" {}

variable "account_id" {}

variable "aws_region" {}

variable "access_ip" {}

variable "key_name" {}

variable "private_subnet_ids" {}

variable "private_security_group_id" {}

variable "kubernetes_version" {
  description = "Cluster Kubernetes version"
  default     = "1.25"
}

# Autoscaler version need to match kubernetes version
# Get available versions from:
# https://console.cloud.google.com/gcr/images/k8s-artifacts-prod/EU/autoscaling/cluster-autoscaler?pli=1
variable "autoscaler_version" {
  description = "Cluster Kubernetes Autoscaler version"
  default     = "1.25.1"
}

variable "create_fargate_profile" {
  default = false
}
