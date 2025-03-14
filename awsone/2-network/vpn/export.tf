# #############################################################################
# Export client configuration
# #############################################################################
locals {
  # https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html#AmazonDNS
  client_dns = ["169.254.169.253", "1.1.1.1", "1.0.0.1"]
  client_routes = flatten([
    var.public_subnets_cidr,
    var.private_subnets_cidr, # All IPs in the VPC
    "169.254.169.253/32",     # AWS DNS
    # "0.0.0.0/32",                # Route all traffic through VPN (uncomment if you want this)
  ])
}

resource "local_file" "peer_conf" {
  for_each = { for index, p in local.secrets.wg_peers : p.name => p }
  filename = "generated/${each.value.name}.conf"

  content = templatefile("${path.module}/templates/client-conf.tftpl", {
    server_addr    = "${aws_eip.wireguard.public_ip}:${local.wg_port}",
    server_pubkey  = local.secrets.wg_server.pubkey,
    client_addr    = each.value.addr,
    client_privkey = each.value.privkey,
    client_dns     = join(",", local.client_dns),
    client_routes  = join(",", local.client_routes),
  })
}
