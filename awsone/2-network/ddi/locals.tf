# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_ddi_va = templatefile("${path.module}/userdata_ddi_va.tftpl", {
  })

  security_groups = {
    data_port = {
      name        = "${var.environment}-sg-ddi-dataport"
      description = "Security group for Deep Discovery Inspector Data Port"
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
      name        = "${var.environment}-sg-ddi-managementport"
      description = "Security group for Deep Discovery Inspector Management Port"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        instance_connect = {
          description = "EC2 Instance Connect"
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = ["3.120.181.40/29", "18.202.216.48/29", "3.8.37.24/29", "35.180.112.80/29", "13.48.4.200/30", "18.206.107.24/29", "3.16.146.0/29", "13.52.6.112/29", "18.237.140.160/29"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr, var.access_ip)
        }
        vxlan = {
          from        = 4789
          to          = 4789
          protocol    = "udp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
        nlb = {
          from        = 14789
          to          = 14789
          protocol    = "udp"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        }
      }
    }
  }
}
