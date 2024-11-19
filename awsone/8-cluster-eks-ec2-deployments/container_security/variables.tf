# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

# Container Security
variable "cluster_arn" {}

variable "cluster_name" {}

variable "cluster_policy" {}

variable "api_key" {}

variable "group_id" {}

variable "namespace" {
  default = "trendmicro-system"
}
