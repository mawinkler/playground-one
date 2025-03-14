################################################################################
# Locals
################################################################################
locals {
  wg_cidr = "172.16.16.0/20" # CIDR of Wireguard Server
  wg_port = 51820            # Port of Wireguard Server
  secrets = yamldecode(file("${path.module}/../../../vpn-secrets.yaml"))

  security_groups = {
    public = {
      name        = "${var.environment}-wireguard"
      description = "Security group for Wireguard Public Access"

      ingress = {
        wireguard = {
          from        = local.wg_port
          to          = local.wg_port
          protocol    = "udp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "Allow Wireguard Traffic"
        }
        instance_connect = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = ["3.120.181.40/29", "18.202.216.48/29", "3.8.37.24/29", "35.180.112.80/29", "13.48.4.200/30", "18.206.107.24/29", "3.16.146.0/29", "13.52.6.112/29", "18.237.140.160/29"]
          description = "EC2 Instance Connect"
        }
      }
    }
  }

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
