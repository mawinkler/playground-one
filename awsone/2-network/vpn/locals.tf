locals {
  server_cert        = file("${path.module}/../pki/server.crt")
  server_private_key = file("${path.module}/../pki/server.key")
  ca_cert            = file("${path.module}/../pki/ca.crt")

  client_cert        = file("${path.module}/../pki/client1.domain.tld.crt")
  client_private_key = file("${path.module}/../pki/client1.domain.tld.key")
}
