# #############################################################################
# EC2 Security Groups
# #############################################################################
resource "aws_security_group" "public_security_group_rds" {
  name        = "${var.environment}-rds-sg-${random_string.suffix.id}"
  description = "Security group for PAP RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"] # Open to all, you may restrict it to specific IP ranges
    cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
  }

  tags = {
    Name          = "${var.environment}-rds-sg-${random_string.suffix.id}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "pap"
  }
}

resource "aws_security_group" "public_security_group_ec2" {
  name        = "${var.environment}-ec2-sg-${random_string.suffix.id}"
  description = "Security group for PAP EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.environment}-ec2-sg-${random_string.suffix.id}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "pap"
  }
}
