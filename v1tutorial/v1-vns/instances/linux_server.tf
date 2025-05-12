# #############################################################################
# Linux Instances
# #############################################################################
resource "aws_instance" "linux-server" {

  count = var.linux_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = var.private_subnets[0]
  vpc_security_group_ids = [var.private_security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-linux-server"
  }

  user_data = local.userdata_linux
}

# Traffic Mirror Session
# A connection between a mirror source and target that makes use of a filter.
# Sessions are numbered, evaluated in order, and the first match (accept or reject)
# is used to determine the fate of the packet. A given packet is sent to at most one target.
resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session_linux" {

  count = length(aws_instance.linux-server)

  description              = "VNS Traffic mirror session - linux Server"
  session_number           = 1 # Session numbers must be unique per ENI, not globally.
  network_interface_id     = aws_instance.linux-server[count.index].primary_network_interface_id
  traffic_mirror_filter_id = var.vns_va_traffic_mirror_filter_id
  traffic_mirror_target_id = var.vns_va_traffic_mirror_target_id

  tags = {
    Name          = "${var.environment}-linux-server-${count.index}-traffic-mirror-session"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "instances"
    Type          = "${var.environment}-linux-server"
  }
}
