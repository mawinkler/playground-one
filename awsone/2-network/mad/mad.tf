# #############################################################################
# MAD deployment
# #############################################################################
resource "aws_directory_service_directory" "ds_managed_ad" {
  name       = "${var.environment}-mad.local"
  short_name = "${var.environment}-mad"
  password   = aws_secretsmanager_secret_version.mad_admin_secret_version.secret_string
  edition    = "Standard"
  type       = local.ds_managed_ad_type

  vpc_settings {
    vpc_id     = var.vpc_id
    # subnet_ids = [var.private_subnets[0], var.private_subnets[1]]
    subnet_ids = [var.public_subnets[0], var.public_subnets[1]]
  }
}

## Sets MAD security group egress

# resource "aws_security_group_rule" "ds_managed_ad_secgroup" {
#   type              = "egress"
#   description       = "Allowing outbound traffic"
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 0
#   security_group_id = aws_directory_service_directory.ds_managed_ad.security_group_id
# }
