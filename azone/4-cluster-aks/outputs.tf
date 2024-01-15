# #############################################################################
# Outputs
# #############################################################################
output "resource_group_name" {
  value = module.aks.resource_group_name
}

output "kubernetes_cluster_name" {
  value = module.aks.kubernetes_cluster_name
}

output "client_certificate" {
  value     = module.aks.client_certificate
  sensitive = true
}

output "client_key" {
  value     = module.aks.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.aks.cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = module.aks.cluster_password
  sensitive = true
}

output "cluster_username" {
  value     = module.aks.cluster_username
  sensitive = true
}

output "host" {
  value     = module.aks.host
  sensitive = true
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "kubectl" {
  value = "kubectl get pods -A --kubeconfig kubeconfig"
}