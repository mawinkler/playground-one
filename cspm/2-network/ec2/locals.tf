################################################################################
# Locals
################################################################################
locals {
  security_groups = {
    public = {
      name        = "${var.environment}-public-sg"
      description = "Security group for Public Access"
      tags = {
        "3ea0ed93-bdcf-456d-adc5-7080ea923bf4" = "module.ec2.aws_security_group.sg[\"public\"]_EC2-001"
        "7f404fd7-4f7b-4ac6-bfcc-512eed878dd0" = "module.ec2.aws_security_group.sg[\"public\"]_EC2-033"
      }
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
      description = "Security group for Private Access"
      tags = {
        "2c277201-31d8-42ac-85e2-bda5dd1ef329" = "module.ec2.aws_security_group.sg[\"private\"]_EC2-033"
      }
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
