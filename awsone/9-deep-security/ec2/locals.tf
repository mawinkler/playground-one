################################################################################
# Locals
################################################################################
locals {
  security_groups = {
    public = {
      name        = "${var.environment}-public-sg"
      description = "Security group for Public Access"
      ingress = {
        ssh = {
          description = "SSH Access"
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
        rdp = {
          description = "RDP Access"
          from        = 3389
          to          = 3389
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        winrm = {
          description = "WinRM Access"
          from        = 5985
          to          = 5986
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        dsm = {
          description = "Deep Security Manager"
          from        = 4118
          to          = 4122
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        dsm_private = {
          description = "Deep Security Manager"
          from        = 4118
          to          = 4122
          protocol    = "tcp"
          cidr_blocks = var.private_subnets_cidr
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
        dsm = {
          description = "Deep Security Manager"
          from        = 4118
          to          = 4122
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
        }
        postgres = {
          from        = 5432
          to          = 5432
          protocol    = "tcp"
          cidr_blocks = var.private_subnets_cidr
        }
      }
    }
  }
}
