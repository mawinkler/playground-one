# ####################################
# Variables
# ####################################
variable "subscription_id" {
  type        = string
  description = "The subscription ID to use."
  default     = ""
}

variable "access_ip" {
  type = string
}

variable "environment" {
  type = string
}
