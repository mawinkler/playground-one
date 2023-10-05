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
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        rdp = {
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
        http = {
          from        = 8080
          to          = 8080
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
        http = {
          from        = 7860
          to          = 7860
          protocol    = "tcp"
          cidr_blocks = var.access_ip
        }
      }
    }

    private = {
      name        = "${var.environment}-private-sg"
      description = "Security group"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
        }
        http = {
          from        = 8080
          to          = 8080
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
        }
      }
    }
  }
}
