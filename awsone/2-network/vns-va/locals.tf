# #############################################################################
# Locals
# #############################################################################
locals {
  security_groups = {
    # https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-aws-security-groups-network-sensor
    data_port = {
      name        = "${var.environment}-sg-vns-dataport"
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
      name        = "${var.environment}-sg-vns-managementport"
      description = "Security group for Virtual Network Sensor Management Port"
      ingress = {
        ssh = {
          # Access CLISH console
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
        http = {
          # Default log export
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
        vxlan = {
          # VXLAN traffic required by the AWS traffic mirror
          from        = 4789
          to          = 4789
          protocol    = "udp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
        healthcheck = {
          # Answer NLB health check
          from        = 14789
          to          = 14789
          protocol    = "tcp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
      }
    }
  }
}
