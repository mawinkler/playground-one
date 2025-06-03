# CUSTOMIZE
# Number of instances and Vision One Deployment here
variable "linux_count" {
  type    = number
  default = 1
}

variable "windows_count" {
  type    = number
  default = 1
}
# /CUSTOMIZE

variable "aws_region" {
  type = string
}

#
# Vision One Endpoint Security
#
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
