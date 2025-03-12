# #############################################################################
# Config Server
# #############################################################################
locals {
  wg_cidr = "172.16.16.0/20" # CIDR of Wireguard Server
  wg_port = 51820            # Port of Wireguard Server
  secrets = yamldecode(file("${path.module}/secrets.yaml"))

  userdata = templatefile("${path.module}/templates/wg-init.tftpl", {
    wg_cidr    = local.wg_cidr
    wg_port    = local.wg_port
    wg_privkey = local.secrets.wg_server.privkey
    wg_peers = join("\n", [
      for p in local.secrets.wg_peers :
      templatefile("${path.module}/templates/wg-peer.tftpl", {
        peer_name   = p.name
        peer_pubkey = p.pubkey
        peer_addr   = p.addr
      })
    ])
  })
}
