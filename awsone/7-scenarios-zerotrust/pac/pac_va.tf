# #############################################################################
# Linux Instance for Service Gateway
# #############################################################################
resource "aws_instance" "pac_va" {

  ami                    = data.aws_ami.pac_va.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.sg_pac_va["public"].id]
  key_name               = var.key_name

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name          = "${var.environment}-pac-va"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "nw"
  }

  user_data = local.userdata_pac_va
}
