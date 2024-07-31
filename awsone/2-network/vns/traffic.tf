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
  depends_on           = [ aws_network_interface.vns_va_ni_data, aws_instance.vns_va ]

  description          = "Data Port Target"
  network_interface_id = aws_network_interface.vns_va_ni_data.id
}

