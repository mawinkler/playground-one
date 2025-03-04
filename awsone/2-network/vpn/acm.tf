resource "aws_acm_certificate" "server_vpn_cert" {
  certificate_body  = local.server_cert
  private_key       = local.server_private_key
  certificate_chain = local.ca_cert
}

resource "aws_acm_certificate" "client_vpn_cert" {
  certificate_body  = local.client_cert
  private_key       = local.client_private_key
  certificate_chain = local.ca_cert
}
