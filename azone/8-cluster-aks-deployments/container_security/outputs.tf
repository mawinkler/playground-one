# #############################################################################
# Outputs
# #############################################################################
output "cluster_id" {
  value = local.cluster_id
}

output "cluster_apikey" {
  value     = local.cluster_apikey
  sensitive = true
}

output "cluster_policy_id" {
  value = local.cluster_policy
}
