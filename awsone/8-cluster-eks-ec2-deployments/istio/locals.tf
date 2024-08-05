locals {
  istio_gateway_service_annotations = {
    "service.beta.kubernetes.io/aws-load-balancer-type" : "external"
    "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" : "ip"
    "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internet-facing"
    "service.beta.kubernetes.io/aws-load-balancer-attributes" : "load_balancing.cross_zone.enabled=true"
  }
}
