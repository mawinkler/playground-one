# #############################################################################
# Traffic Mirror
# #############################################################################
# https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-network-sensor-traffic-mirror
# Here, we define what traffic gets mirrored which is all ingress and egress and are including amazon-dns
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
