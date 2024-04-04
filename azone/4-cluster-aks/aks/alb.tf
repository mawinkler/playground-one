# resource "azurerm_application_load_balancer" "alb" {
#   name                = "${var.environment}-alb-${random_pet.pet.id}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
# }
