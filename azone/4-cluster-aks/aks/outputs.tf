output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config
  sensitive = true
}

output "update_local_context_command" {
  description = "Command to update local kube context"
  value       = "KUBECONFIG=~/.kube/config:$ONEPATH/azone/4-cluster-aks/kubeconfig kubectl config view --flatten > /tmp/config && mv /tmp/config ~/.kube/config"
}

resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.aks]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.aks.kube_config_raw
}
