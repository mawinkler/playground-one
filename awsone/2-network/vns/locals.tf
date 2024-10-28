# #############################################################################
# Locals
# #############################################################################
locals {
  security_groups = {
    data_port = {
      name        = "${var.environment}-sg-vms-dataport"
      description = "Security group for Virtual Network Sensor Data Port"
      ingress = {
        inspection_traffic = {
          from        = 0
          to          = 0
          protocol    = -1
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
      }
    }

    management_port = {
      name        = "${var.environment}-sg-vms-managementport"
      description = "Security group for Virtual Network Sensor Management Port"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        vxlan = {
          from        = 4789
          to          = 4789
          protocol    = "udp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
        healthcheck = {
          from        = 14789
          to          = 14789
          protocol    = "tcp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
      }
    }
  }
}
