variable "aws_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "access_ip" {
  type = list(any)
}

variable "environment" {
  type = string
}

variable "one_path" {
  type = string
}

variable "linux_username" {
  type = string
}

# Deploy Vision One Endpoint Agent
variable "agent_deploy" {
  type = bool
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

variable "create_linux" {
  type = bool
  default = true
}