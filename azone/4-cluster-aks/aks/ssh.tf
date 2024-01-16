resource "random_pet" "ssh_key_name" {
  prefix    = "${var.resource_group_name_prefix}-ssh"
}

resource "azurerm_ssh_public_key" "ssh_public_key" {
  name                = random_pet.ssh_key_name.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = file("~/.ssh/id_rsa.pub")
}
