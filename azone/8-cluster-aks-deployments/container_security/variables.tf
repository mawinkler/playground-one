# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

# Container Security
variable "cluster_name" {}

variable "cluster_policy" {}

variable "api_key" {}

variable "namespace" {
  default = "trendmicro-system"
}
