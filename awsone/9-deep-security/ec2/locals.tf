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
