resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "${var.resource_group_name_prefix}-aks"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "${var.resource_group_name_prefix}-dns"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                              = random_pet.azurerm_kubernetes_cluster_name.id
  location                          = azurerm_resource_group.rg.location
  resource_group_name               = azurerm_resource_group.rg.name
  dns_prefix                        = random_pet.azurerm_kubernetes_cluster_dns_prefix.id
  http_application_routing_enabled  = true
  role_based_access_control_enabled = true

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = var.network_plugin
  }

  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub") #jsondecode(azurerm_ssh_public_key.ssh_public_key.output).publicKey
    }
  }

  #   network_profile {
  #     network_plugin    = "kubenet"
  #     load_balancer_sku = "standard"
  #   }

  tags = {
    Name          = "${var.resource_group_name_prefix}-aks-std"
    Environment   = "${var.resource_group_name_prefix}"
    Product       = "playground-one"
    Configuration = "aks-std"
  }
}
