# #############################################################################
# Locals
# #############################################################################
locals {
  userdata_pac_va = templatefile("${path.module}/userdata_pac_va.tftpl", {
    # registration_token = var.registration_token
  })

  security_groups = {
    public = {
      name        = "${var.environment}-public-sg-pac-va"
      description = "Security group for Private Access Connector"
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
        # http = {
        #   from        = 80
        #   to          = 80
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
        # https = {
        #   from        = 443
        #   to          = 443
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
        # wrs_1 = {
        #   from        = 5274
        #   to          = 5274
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
        # wrs_2 = {
        #   from        = 5275
        #   to          = 5275
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
        # fwd = {
        #   from        = 8080
        #   to          = 8080
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
        # zta = {
        #   from        = 8088
        #   to          = 8088
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
        # zta = {
        #   from        = 8089
        #   to          = 8089
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
        # zta_icap = {
        #   from        = 1344
        #   to          = 1344
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
        # zta_icap = {
        #   from        = 11344
        #   to          = 11344
        #   protocol    = "tcp"
        #   cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
        # }
      }
    }
  }
}
