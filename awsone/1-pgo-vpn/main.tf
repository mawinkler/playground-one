module "vpn" {
  source = "./vpn"

  access_ip   = var.access_ip
  environment = var.environment
}
