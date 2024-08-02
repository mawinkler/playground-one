# ####################################
# Istio gateway
# ####################################
# Install an ingress gateway
resource "helm_release" "gateway" {
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  name             = "istio-gateway"
  namespace        = var.namespace_ingress
  create_namespace = true
  version          = "1.22.3"
  wait             = true

  depends_on = [
    helm_release.istio_base,
    helm_release.istio_cni,
    helm_release.istiod
  ]
}
