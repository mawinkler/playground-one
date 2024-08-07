# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "cluster_arn" {}

variable "cluster_name" {}

variable "cluster_policy" {}

variable "group_id" {}

variable "namespace" {
  default = "trendmicro-system"
}
