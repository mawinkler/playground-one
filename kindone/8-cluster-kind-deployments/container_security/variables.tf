# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

# Container Security
variable "cluster_name" {}

variable "cluster_policy" {}

variable "api_key" {}

variable "registration_key" {}

variable "group_id" {}

variable "namespace" {
  default = "trendmicro-system"
}
