# #############################################################################
# Traffic Mirror
# #############################################################################
resource "aws_ec2_traffic_mirror_filter" "vns_traffic_filter" {
  description      = "VirtualNetworkSensor-TrafficMirrorFilter"
  network_services = ["amazon-dns"]
}

resource "aws_ec2_traffic_mirror_filter_rule" "vns_traffic_filter_in" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.vns_traffic_filter.id
  rule_number              = 100
  rule_action              = "accept"
  protocol                 = 0
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  description              = "Mirror all inbound traffic"
  traffic_direction        = "ingress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "vns_traffic_filter_out" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.vns_traffic_filter.id
  rule_number              = 100
  rule_action              = "accept"
  protocol                 = 0
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  description              = "Mirror all outbound traffic"
  traffic_direction        = "egress"
}

resource "aws_ec2_traffic_mirror_target" "vns_traffic_filter_target" {
  description          = "Data Port Target"
  network_interface_id = aws_network_interface.vns_va_ni_data.id
}

resource "aws_ec2_traffic_mirror_session" "vns_traffic_mirror_session" {
  description              = "VNS Traffic mirror session - linux_web"
  session_number           = 1
  network_interface_id     = "eni-01b3fee96390b91bb" # aws_instance.test.primary_network_interface_id
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.vns_traffic_filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.vns_traffic_filter_target.id
}
