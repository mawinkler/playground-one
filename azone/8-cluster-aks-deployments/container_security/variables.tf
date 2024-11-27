# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

# Container Security
variable "cluster_name" {}

variable "cluster_policy" {}

variable "cluster_policy_operator" {}

variable "api_key" {}

variable "namespace" {
  default = "trendmicro-system"
}
