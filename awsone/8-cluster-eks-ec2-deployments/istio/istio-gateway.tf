# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm repo update
# helm install gateway -n istio-ingress --create-namespace istio/gateway
resource "helm_release" "gateway" {
  name = "istio-gateway"

  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = var.namespace_ingress
  create_namespace = true
  version          = "1.22.3"

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod
  ]
}
