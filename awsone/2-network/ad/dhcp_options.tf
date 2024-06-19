resource "aws_vpc_dhcp_options" "vpc-dhcp-options" {
  domain_name_servers = [aws_instance.windows-server-dc.private_ip]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.vpc-dhcp-options.id
}
