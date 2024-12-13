# #############################################################################
# Outputs
# #############################################################################
output "loadbalancer_port_forward" {
  value = "kubectl -n projectcontour port-forward service/contour-envoy ${local.forward_port}:80 --address='0.0.0.0'"
}

output "loadbalancer_ip_range" {
  value = cidrsubnet(data.external.kind_network_inspect.result.Subnet, 12, 8)
}