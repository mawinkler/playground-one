# ####################################
# Istio discovery
# ####################################
# Install the Istio discovery chart which deploys the istiod service
resource "helm_release" "istiod" {

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  name             = "istiod"
  namespace        = var.namespace_base
  create_namespace = true
  version          = "1.22.3"
  wait             = true

  set {
    name  = "global.istioNamespace"
    value = var.namespace_base
  }

  set {
    name  = "meshConfig.ingressService"
    value = "istio-gateway"
  }

  set {
    name  = "meshConfig.ingressSelector"
    value = "gateway"
  }

  set {
    name  = "telemetry.enabled"
    value = "true"
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istio_cni
  ]
}
