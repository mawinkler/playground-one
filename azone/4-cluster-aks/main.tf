module "aks" {
  source                     = "./aks"
  resource_group_location    = var.resource_group_location
  resource_group_name_prefix = var.environment
  node_count                 = var.node_count
  username                   = var.username
  access_ip                  = var.access_ip
}
