# ####################################
# Istio gateway
# ####################################
# Install an ingress gateway
resource "helm_release" "gateway" {
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  name             = "istio-ingressgateway"
  namespace        = var.namespace_base  #var.namespace_ingress
  create_namespace = true
  version          = "1.22.3"
  wait             = true


  set {
    name  = "labels.istio"
    value = "ingressgateway"
  }

  dynamic "set" {
    for_each = local.istio_gateway_service_annotations
    content {
      name  = "service.annotations.${replace(set.key, ".", "\\.")}"
      value = set.value
    }
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istio_cni,
    helm_release.istiod
  ]
}
