# #############################################################################
# Linux Instance for Service Gateway
# #############################################################################
resource "aws_instance" "sg_va" {

  ami                    = data.aws_ami.sg_va.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.sg_sg_va["public"].id]  # [var.public_security_group_id]
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-sg-va"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "dsm"
  }

  user_data = local.userdata_sg_va
}
