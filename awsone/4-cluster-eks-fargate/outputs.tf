# #############################################################################
# Outputs
# #############################################################################
output "update_local_context_command" {
  description = "Update local Cluster Context command"
  value       = module.eks-fargate.update_local_context_command
}

output "cluster_arn" {
  description = "Cluster ARN"
  value       = module.eks-fargate.cluster_arn
}

output "cluster_name" {
  description = "Cluster Name"
  value       = module.eks-fargate.cluster_name
}
