# #############################################################################
# Traffic Mirror
# #############################################################################
resource "aws_ec2_traffic_mirror_filter" "ddi_traffic_filter" {
  description      = "DeepDiscoveryInspector-TrafficMirrorFilter"
  network_services = ["amazon-dns"]
}

resource "aws_ec2_traffic_mirror_filter_rule" "ddi_traffic_filter_in" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.ddi_traffic_filter.id
  rule_number              = 100
  rule_action              = "accept"
  protocol                 = 0
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  description              = "Mirror all inbound traffic"
  traffic_direction        = "ingress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "ddi_traffic_filter_out" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.ddi_traffic_filter.id
  rule_number              = 100
  rule_action              = "accept"
  protocol                 = 0
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  description              = "Mirror all outbound traffic"
  traffic_direction        = "egress"
}

resource "aws_ec2_traffic_mirror_target" "ddi_traffic_filter_target" {
  depends_on           = [ aws_network_interface.ddi_va_ni_data_public, aws_instance.ddi_va ]

  description          = "Data Port Target"
  network_interface_id = aws_network_interface.ddi_va_ni_data_public.id
}

