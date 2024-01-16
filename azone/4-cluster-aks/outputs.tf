# #############################################################################
# Outputs
# #############################################################################
output "resource_group_name" {
  value = module.aks.resource_group_name
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "update_local_context_command" {
  description = "Update local Cluster Context command"
  value       = module.aks.update_local_context_command
}
