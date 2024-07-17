# #############################################################################
# EC2 Security Groups
# #############################################################################
resource "aws_security_group" "public_security_group_ec2" {
  name        = "${var.environment}-target-sg-${random_string.suffix.id}"
  description = "Security group for target EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.access_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.environment}-target-sg-${random_string.suffix.id}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "scenarios-cloudtrail"
  }
}
