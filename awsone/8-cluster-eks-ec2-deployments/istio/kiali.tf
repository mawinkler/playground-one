# ####################################
# Kiali
# ####################################
resource "helm_release" "kiali" {
  repository       = "https://kiali.org/helm-charts"
  chart            = "kiali-operator"
  name             = "kiali-operator"
  namespace        = "kiali-operator"
  create_namespace = true
  # version          = "1.22.3"
  # wait             = true

  set {
    name  = "cr.create"
    value = true
  }

  set {
    name  = "cr.namespace"
    value = var.namespace_base
  }

  set {
    name  = "cr.spec.auth.strategy"
    value = "anonymous"
  }

  depends_on = [
    helm_release.istio_base,
    helm_release.istio_cni,
    helm_release.istiod
  ]
}
