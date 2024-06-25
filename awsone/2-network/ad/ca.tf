# Create EC2 Instance
resource "aws_instance" "windows-server-ca" {
  ami                    = data.aws_ami.windows-server.id
  instance_type          = var.windows_instance_type
  subnet_id              = var.public_subnets[0]
  vpc_security_group_ids = [var.public_security_group_id]
  source_dest_check      = false
  key_name               = var.key_name
  user_data              = local.userdata_ca

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.environment}-windows-server-ca"
    Environment = var.environment
  }
}
