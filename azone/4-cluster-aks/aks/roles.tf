resource "azurerm_role_assignment" "Network_Contributor_subnet" {
  scope                = data.azurerm_subnet.appgwsubnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "rg_reader" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}

resource "azurerm_role_assignment" "app-gw-contributor" {
  scope                = azurerm_application_gateway.network.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
