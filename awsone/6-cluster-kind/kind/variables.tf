# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "one_path" {}

variable "kubernetes_version" {
  description = "Cluster Kubernetes version"
  default     = "1.27.1"
}
