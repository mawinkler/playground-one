################################################################################
# Locals
################################################################################
locals {
  security_groups = {
    public = {
      name        = "${var.environment}-public-sg"
      description = "Security group for Public Access"
      ingress = {
        vpc = {
          from        = 0
          to          = 0
          protocol    = "all"
          cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
          description = "Allow All Connections From VPC"
        }
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Allow SSH Access"
        }
        instance_connect = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = ["3.120.181.40/29", "18.202.216.48/29", "3.8.37.24/29", "35.180.112.80/29", "13.48.4.200/30", "18.206.107.24/29", "3.16.146.0/29", "13.52.6.112/29", "18.237.140.160/29"]
          description = "EC2 Instance Connect"
        }
      }
    }

    private = {
      name        = "${var.environment}-private-sg"
      description = "Security group for Private Access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
        }
      }
    }
  }

  userdata_pgo_satellite = templatefile("${path.module}/userdata_linux.tftpl", {
    s3_bucket      = var.s3_bucket
    linux_hostname = "pgo_satellite"
    tm_agent       = var.agent_variant
  })
}
