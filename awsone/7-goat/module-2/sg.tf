# #############################################################################
# Security Groups
# #############################################################################
resource "aws_security_group" "ecs_sg" {
  name        = "${var.environment}-ecs-sg-${random_string.suffix.result}"
  description = "SG for cluster created from terraform"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.environment}-ecs-sg"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "goat"
  }
}

resource "aws_security_group" "database-security-group" {
  name        = "${var.environment}-db-sg-${random_string.suffix.result}"
  description = "Enable MYSQL Aurora access on Port 3306"
  vpc_id      = var.vpc_id #aws_vpc.lab-vpc.id

  ingress {
    description     = "MYSQL/Aurora Access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ecs_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${var.environment}-db-sg"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "goat"
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  name        = "${var.environment}-lb-sg-${random_string.suffix.result}"
  description = "SG for load balancer created from terraform"
  vpc_id      = var.vpc_id #aws_vpc.lab-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name          = "${var.environment}-lb-sg"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "goat"
  }
}
