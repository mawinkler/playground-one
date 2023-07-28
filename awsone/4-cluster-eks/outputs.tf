# #############################################################################
# Outputs
# #############################################################################
output "update_local_context_command" {
  description = "Update local Cluster Context command"
  value       = module.eks.update_local_context_command
}
