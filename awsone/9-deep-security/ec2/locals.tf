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
          from        = 4119
          to          = 4119
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        activation = {
          description = "Deep Security Activation"
          from        = 4120
          to          = 4120
          protocol    = "tcp"
          cidr_blocks = var.access_ip
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
          from        = 4119
          to          = 4119
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
        }
        activation = {
          description = "Deep Security Activation"
          from        = 4120
          to          = 4120
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
