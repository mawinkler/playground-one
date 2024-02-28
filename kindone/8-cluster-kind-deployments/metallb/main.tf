data "external" "kind_network_inspect" {
  program = ["bash", "${path.module}/get_docker_network_ip.sh"]
}

resource "helm_release" "metallb" {
  # https://artifacthub.io/packages/helm/metallb/metallb/0.14.3
  depends_on = [kubernetes_namespace_v1.metallb_system_namespace]
  chart      = "https://github.com/metallb/metallb/releases/download/metallb-chart-0.14.3/metallb-0.14.3.tgz"
  name       = "metallb"
  namespace  = var.namespace

  set {
    name  = "version"
    value = "0.14.3"
  }
}

resource "kubectl_manifest" "kind_address_pool" {
  depends_on = [helm_release.metallb]
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: main-address
  namespace: ${var.namespace}
spec:
  addresses:
  - ${data.external.kind_network_inspect.result.Subnet}
YAML
}

resource "helm_release" "projectcontour" {
  depends_on = [helm_release.metallb]

  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "contour"
  name             = "contour"
  namespace        = "projectcontour"
  version          = "12.1.0"
  create_namespace = true
}
