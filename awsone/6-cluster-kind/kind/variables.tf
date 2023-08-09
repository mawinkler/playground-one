# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "kubernetes_version" {
  description = "Cluster Kubernetes version"
  default     = "1.27.1"
}
