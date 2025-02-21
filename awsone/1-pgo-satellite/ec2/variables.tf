# #############################################################################
# Variables
# #############################################################################
variable "environment" {}

variable "access_ip" {}

variable "one_path" {}

variable "vpc_id" {}

variable "public_subnets_cidr" {}

variable "private_subnets_cidr" {}

variable "private_subnets" {}

variable "private_subnet" {
  type    = bool
  default = false
}

variable "private_route_tables" {}

variable "create_linux" {}

variable "pgo_instance_type" {
  type        = string
  description = "EC2 instance type for PGO Satellite"
  default     = "t3.medium"
}
variable "ec2_profile" {}

variable "s3_bucket" {}

variable "pgo_satellite_count" {
  type    = number
  default = 1
}

variable "linux_username" {
  type = string
}

# Deploy Vision One Endpoint Agent
variable "agent_deploy" {
  type    = bool
  default = false
}

variable "agent_variant" {
  type = string
  # Which agent to deploy?
  # Allowed values:
  #   TMServerAgent (Server and Workload Security)
  #   TMSensorAgent (Basecamp)
  default = "TMServerAgent"
}

variable "public_subnets" {}
