# #############################################################################
# Main
# #############################################################################
module "scanner" {
  source            = "./scanner"
  environment       = var.environment
  aws_region        = var.aws_region
  vision_one_region = var.vision_one_region
  api_key           = var.api_key
}
