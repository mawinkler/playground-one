# #############################################################################
# Create Security Group
# #############################################################################
resource "aws_security_group" "wireguard" {
  name        = "${local.vpc_name}-wireguard"
  description = "SG for Wireguard VPN Server"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = local.wg_port
    to_port     = local.wg_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Wireguard Traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.environment}-wireguard"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}
