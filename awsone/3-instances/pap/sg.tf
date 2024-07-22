# #############################################################################
# EC2 Security Groups
# #############################################################################
# resource "aws_security_group" "public_security_group_rds" {
#   name        = "${var.environment}-rds-sg-${random_string.suffix.id}"
#   description = "Security group for PAP RDS instance"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port = 5432
#     to_port   = 5432
#     protocol  = "tcp"
#     # cidr_blocks = ["0.0.0.0/0"] # Open to all, you may restrict it to specific IP ranges
#     cidr_blocks = setunion(var.public_subnets_cidr, var.private_subnets_cidr)
#   }

#   tags = {
#     Name          = "${var.environment}-rds-sg-${random_string.suffix.id}"
#     Environment   = "${var.environment}"
#     Product       = "playground-one"
#     Configuration = "pap"
#   }
# }

# resource "aws_security_group" "public_security_group_ec2" {
#   name        = "${var.environment}-ec2-sg-${random_string.suffix.id}"
#   description = "Security group for PAP EC2 instance"
#   vpc_id      = var.vpc_id

#   # ingress {
#   #   ssh = {
#   #     from        = 22
#   #     to          = 22
#   #     protocol    = "tcp"
#   #     cidr_blocks = var.access_ip
#   #   }
#   #   redis = {
#   #     from        = 6379
#   #     to          = 6379
#   #     protocol    = "tcp"
#   #     cidr_blocks = ["0.0.0.0/0"]
#   #   }
#   # }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name          = "${var.environment}-ec2-sg-${random_string.suffix.id}"
#     Environment   = "${var.environment}"
#     Product       = "playground-one"
#     Configuration = "pap"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
#   security_group_id = aws_security_group.public_security_group_ec2.id
#   cidr_ipv4         = var.access_ip
#   from_port         = 22
#   to_port           = 22
#   ip_protocol       = "tcp"
# }

# resource "aws_vpc_security_group_ingress_rule" "allow_redis" {
#   security_group_id = aws_security_group.public_security_group_ec2.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 6379
#   to_port           = 6379
#   ip_protocol       = "tcp"
# }

resource "aws_security_group" "sg" {
  for_each    = local.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${each.value.name}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "pap"
  }
}
