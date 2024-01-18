# #############################################################################
# Outputs
# #############################################################################
output "resource_group_name" {
  value = module.aks.resource_group_name
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "cluster_username" {
  value     =  module.aks.cluster_username
  sensitive = true
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "update_local_context_command" {
  description = "Update local Cluster Context command"
  value       = module.aks.update_local_context_command
}
