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
      # description = ingress.value.description
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
    Configuration = "nw"
  }
}

# (ASRM Scenario)
resource "aws_security_group" "sg_inet" {
  for_each    = local.security_groups
  name        = "${each.value.name}-inet"
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = var.create_attackpath ? ["0.0.0.0/0"] : ingress.value.cidr_blocks
      # description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name          = "${each.value.name}-inet"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }
}
