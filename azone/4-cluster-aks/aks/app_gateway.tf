# #############################################################################
# App Gateway
# #############################################################################
data "azurerm_subnet" "appgwsubnet" {
  depends_on = [azurerm_subnet.app_gwsubnet]

  name                 = var.subnet_address_name
  virtual_network_name = "${var.environment}-vnet-${random_pet.pet.id}"
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "azurerm_application_gateway" "network" {
  name                = "${var.environment}-appgw-${random_pet.pet.id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.appgwsubnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.publicip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 100
  }

  tags = {
    Name          = "${var.environment}-aks-std"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "aks-std"
  }

  depends_on = [azurerm_public_ip.publicip]

  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      request_routing_rule,
      http_listener,
      probe,
      tags,
      frontend_port
    ]
  }
}
