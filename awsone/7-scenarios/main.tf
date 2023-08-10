module "victims" {
  source      = "./victims"
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "victims"
}

module "goat" {
  source      = "./goat"
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "goat"
}

module "attackers" {
  source      = "./attackers"
  environment = var.environment
  access_ip   = var.access_ip
  namespace   = "attackers"
}
