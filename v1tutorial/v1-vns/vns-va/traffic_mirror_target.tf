# #############################################################################
# Traffic Mirror
# #############################################################################
# https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-network-sensor-traffic-mirror
# These are the Mirror Target Definitions, one for the public, one for the private subnet.
resource "aws_ec2_traffic_mirror_target" "vns_traffic_filter_target_private" {
  depends_on           = [ aws_network_interface.vns_va_ni_data_private, aws_instance.vns_va ]

  description          = "Data Port Target Private"
  network_interface_id = aws_network_interface.vns_va_ni_data_private.id
}

resource "aws_ec2_traffic_mirror_target" "vns_traffic_filter_target_public" {
  depends_on           = [ aws_network_interface.vns_va_ni_data_public, aws_instance.vns_va ]

  description          = "Data Port Target Public"
  network_interface_id = aws_network_interface.vns_va_ni_data_public.id
}
