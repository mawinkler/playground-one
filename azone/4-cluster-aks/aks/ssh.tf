resource "random_pet" "ssh_key_name" {
  prefix    = "${var.resource_group_name_prefix}-ssh"
}

resource "azurerm_ssh_public_key" "ssh_public_key" {
  name                = random_pet.ssh_key_name.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = file("~/.ssh/id_rsa.pub")
}


# resource "azapi_resource_action" "ssh_public_key_gen" {
#   type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   resource_id = azapi_resource.ssh_public_key.id
#   action      = "generateKeyPair"
#   method      = "POST"

#   response_export_values = ["publicKey", "privateKey"]
# }

# resource "azapi_resource" "ssh_public_key" {
#   type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
#   name      = random_pet.ssh_key_name.id
#   location  = azurerm_resource_group.rg.location
#   parent_id = azurerm_resource_group.rg.id
# }

# output "key_data" {
#   value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
# }
