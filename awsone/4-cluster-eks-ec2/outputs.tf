# #############################################################################
# Outputs
# #############################################################################
output "update_local_context_command" {
  description = "Update local Cluster Context command"
  value       = module.eks.update_local_context_command
}

output "cluster_arn" {
  description = "Cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_name" {
  description = "Cluster Name"
  value       = module.eks.cluster_name
}
