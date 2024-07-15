# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "cluster_arn" {}

variable "cluster_name" {}

variable "cluster_policy" {}

variable "namespace" {
  default = "trendmicro-system"
}
