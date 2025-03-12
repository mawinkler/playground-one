resource "aws_ec2_client_vpn_network_association" "client_vpn_association_private" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  # subnet_id              = tolist(module.vpc.private_subnets)[0]
  subnet_id = tolist(var.private_subnets)[0]
}

resource "aws_ec2_client_vpn_network_association" "client_vpn_association_public" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  # subnet_id              = tolist(module.vpc.public_subnets)[1]
  subnet_id = tolist(var.public_subnets)[1]
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id

  target_network_cidr  = "10.0.0.0/16"
  authorize_all_groups = true
}
