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
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Allow HTTP Access"
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Allow HTTPS Access"
        }
        rdp = {
          from        = 3389
          to          = 3389
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Allow RDP Access"
        }
        winrm = {
          from        = 5985
          to          = 5986
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Allow WinRM Access"
        }
        http = {
          from        = 8080
          to          = 8080
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Allow HTTP Access on port 8080"
        }
        http = {
          from        = 7860
          to          = 7860
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Allow Access on port 7860"
        }
        dsm = {
          from        = 4118
          to          = 4122
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Deep Security Manager"
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
          description = "Allow SSH Access"
        }
        instance_connect = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = ["3.120.181.40/29", "18.202.216.48/29", "3.8.37.24/29", "35.180.112.80/29", "13.48.4.200/30", "18.206.107.24/29", "3.16.146.0/29", "13.52.6.112/29", "18.237.140.160/29"]
          description = "EC2 Instance Connect"
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
          description = "Allow HTTP Access"
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
          description = "Allow HTTPS Access"
        }
        rdp = {
          from        = 3389
          to          = 3389
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
          description = "Allow RDP Access"
        }
        winrm = {
          from        = 5985
          to          = 5986
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
          description = "Allow WinRM Access"
        }
        http = {
          from        = 8080
          to          = 8080
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
          description = "Allow HTTP Access on port 8080"
        }
        http = {
          from        = 7860
          to          = 7860
          protocol    = "tcp"
          cidr_blocks = var.access_ip
          description = "Allow Access on port 7860"
        }
        dsm = {
          from        = 4118
          to          = 4122
          protocol    = "tcp"
          cidr_blocks = var.public_subnets_cidr
          description = "Deep Security Manager"
        }
        postgres = {
          from        = 5432
          to          = 5432
          protocol    = "tcp"
          cidr_blocks = var.private_subnets_cidr
          description = "PostgreSQL"
        }
      }
    }
  }
}
