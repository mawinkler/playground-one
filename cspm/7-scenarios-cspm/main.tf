resource "random_string" "random_root" {
  length  = 8
  special = false
  upper   = false
}

module "s3" {
  source      = "./s3"
  environment = var.environment
}
