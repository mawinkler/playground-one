# #############################################################################
# Main
# #############################################################################
module "credentials" {
  source = "./credentials"

  environment = var.environment
}

module "s3" {
  source = "./s3"

  environment = var.environment
}

data "external" "attack" {
  depends_on = [module.credentials, module.s3]

  program = ["bash", "${path.module}/attack.sh"]
}
