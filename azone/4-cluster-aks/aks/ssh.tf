# #############################################################################
# SSH Key
# #############################################################################
resource "azurerm_ssh_public_key" "ssh_public_key" {
  name                = "${var.environment}-ssh-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = file("~/.ssh/id_rsa.pub")
}
