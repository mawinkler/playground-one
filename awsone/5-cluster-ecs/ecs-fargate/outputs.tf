# #############################################################################
# Outputs
# #############################################################################
output "cluster_name" {
  value = module.ecs.cluster_name
}

output "loadbalancer_dns" {
  value = module.alb.lb_dns_name
}
