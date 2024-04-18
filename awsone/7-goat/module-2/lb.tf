# #############################################################################
# Application Load Balancer
# #############################################################################
resource "aws_alb" "application_load_balancer" {
  name               = "${var.environment}-alb-${random_string.suffix.result}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnets #[aws_subnet.lab-subnet-public-1.id, aws_subnet.lab-subnet-public-1b.id]
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name          = "${var.environment}-alb"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "goat"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.environment}-alb-tg-${random_string.suffix.result}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id #aws_vpc.lab-vpc.id

  tags = {
    Name          = "${var.environment}-alb-tg"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "goat"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}
