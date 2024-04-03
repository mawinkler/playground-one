# #############################################################################
# AKS Cluster
# #############################################################################
data "azurerm_resource_group" "rg" {
  depends_on = [azurerm_resource_group.rg]

  name = "${var.environment}-rg-${random_pet.pet.id}"
}

data "azurerm_subnet" "akssubnet" {
  depends_on = [azurerm_subnet.aks_subnet]

  name                 = var.aks_subnet_address_name
  virtual_network_name = "${var.environment}-vnet-${random_pet.pet.id}"
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [
    azurerm_application_gateway.network
  ]

  name                              = "${var.environment}-aks-${random_pet.pet.id}"
  location                          = azurerm_resource_group.rg.location
  resource_group_name               = azurerm_resource_group.rg.name
  dns_prefix                        = "${var.environment}-dns-${random_pet.pet.id}"
  node_resource_group               = "${var.environment}-node-rg-${random_pet.pet.id}"
  role_based_access_control_enabled = true
  http_application_routing_enabled  = false
  azure_policy_enabled              = true

  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub") #jsondecode(azurerm_ssh_public_key.ssh_public_key.output).publicKey
    }
  }

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = data.azurerm_subnet.akssubnet.id
    type           = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  ingress_application_gateway {
    # subnet_id = data.azurerm_subnet.appgwsubnet.id
    gateway_id = azurerm_application_gateway.network.id
  }

  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = "standard"
    network_policy    = var.network_policy
  }

  tags = {
    Name          = "${var.environment}-aks-std"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "aks-std"
  }
}

data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  username               = azurerm_kubernetes_cluster.aks.kube_config.0.username
  password               = azurerm_kubernetes_cluster.aks.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}
