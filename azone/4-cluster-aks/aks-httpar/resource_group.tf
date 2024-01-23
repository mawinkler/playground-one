# #############################################################################
# Resource Group
# #############################################################################
resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-rg-${random_pet.pet.id}"
  location = var.resource_group_location
}
