# #############################################################################
# Public IP for App Gateway
# #############################################################################
resource "azurerm_public_ip" "publicip" {
  name                = "${var.environment}-publicip-${random_pet.pet.id}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name          = "${var.environment}-aks-std"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "aks-std"
  }
}
