# #############################################################################
# Create
#   Security Group
# #############################################################################
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
    Name        = "${var.environment}-security-group"
    Environment = "${var.environment}"
  }
}

# resource "aws_security_group" "sg_public" {
#   # for_each    = var.security_groups
#   name        = var.security_groups.public.name
#   description = var.security_groups.public.description
#   vpc_id      = var.vpc_id

#   dynamic "ingress" {
#     for_each = var.security_groups.public.ingress

#     content {
#       from_port   = ingress.value.from
#       to_port     = ingress.value.to
#       protocol    = ingress.value.protocol
#       cidr_blocks = ingress.value.cidr_blocks
#     }
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "${var.environment}-security-group"
#     Environment = "${var.environment}"
#   }
# }

# resource "aws_security_group" "sg_private" {
#   # for_each    = var.security_groups
#   name        = var.security_groups.private.name
#   description = var.security_groups.private.description
#   vpc_id      = var.vpc_id

#   dynamic "ingress" {
#     for_each = var.security_groups.private.ingress

#     content {
#       from_port   = ingress.value.from
#       to_port     = ingress.value.to
#       protocol    = ingress.value.protocol
#       # cidr_blocks = ingress.value.cidr_blocks
#       security_groups = [aws_security_group.sg_public.id]
#     }
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "${var.environment}-security-group"
#     Environment = "${var.environment}"
#   }
# }
