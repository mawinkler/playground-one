# data "terraform_remote_state" "vpc" {
#   backend = "local"

#   config = {
#     path = "../2-network/terraform.tfstate"
#   }
# }

module "vm" {
  source                     = "./vm"
  resource_group_location    = var.resource_group_location
  resource_group_name_prefix = var.resource_group_name_prefix
  username                   = var.username
  environment                = var.environment
  create_linux               = var.create_linux
  create_windows             = var.create_windows
}
