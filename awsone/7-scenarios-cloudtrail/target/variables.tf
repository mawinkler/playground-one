# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "access_ip" {}

variable "vpc_id" {}

variable "public_subnets" {}

# Instance
variable "linux_username" {}

variable "linux_hostname" {}

variable "linux_instance_type" {
  type        = string
  description = "EC2 PAP instance type for Linux Server"
  default     = "t3.micro"
}
