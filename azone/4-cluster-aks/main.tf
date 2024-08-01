module "aks" {
  source                  = "./aks"
  resource_group_location = var.resource_group_location
  environment             = var.environment
  node_count              = var.node_count
  username                = var.username
  access_ip               = var.access_ip
  
  # AzureLinux, Ubuntu, Windows2019 and Windows2022
  node_os_sku = "AzureLinux"
}
