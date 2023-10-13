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

# Fargate
variable "create_fargate_profile" {
  default = false
}

# Autoscaler
variable "autoscaler_enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled."
}

variable "autoscaler_service_account_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "Cluster Autoscaler service account name"
}

variable "autoscaler_helm_chart_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "Cluster Autoscaler Helm chart name to be installed"
}

variable "autoscaler_helm_chart_release_name" {
  type        = string
  default     = "cluster-autoscaler"
  description = "Helm release name"
}

variable "autoscaler_helm_chart_version" {
  type        = string
  default     = "9.29.3"
  description = "Cluster Autoscaler Helm chart version."
}

variable "autoscaler_helm_chart_repo" {
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
  description = "Cluster Autoscaler repository name."
}

variable "autoscaler_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create Kubernetes namespace with name defined by `namespace`."
}

variable "autoscaler_namespace" {
  type        = string
  default     = "kube-system"
  description = "Kubernetes namespace to deploy Cluster Autoscaler Helm chart."
}

# variable "autoscaler_dependency" {
#   default     = "autoscaler"
#   description = "Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable."
# }

variable "autoscaler_additional_settings" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values."
}