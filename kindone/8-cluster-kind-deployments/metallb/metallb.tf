# #############################################################################
# Deploy MetalLB
# #############################################################################
data "external" "kind_network_inspect" {
  program = ["bash", "${path.module}/get_docker_network_ip.sh"]
}

resource "helm_release" "metallb" {
  # https://artifacthub.io/packages/helm/metallb/metallb
  depends_on = [kubernetes_namespace_v1.metallb_system_namespace]
  chart      = "https://github.com/metallb/metallb/releases/download/metallb-chart-${local.metallb_version}/metallb-${local.metallb_version}.tgz"
  name       = "metallb"
  namespace  = var.namespace

  set {
    name  = "version"
    value = local.metallb_version
  }
}

# resource "kubernetes_manifest" "kind_address_pool" {
#   depends_on = [helm_release.metallb]
#   manifest = {
#     "apiVersion": "metallb.io/v1beta1"
#     "kind": "IPAddressPool"
#     "metadata": {
#       "name": "main-address"
#       "namespace": var.namespace
#     }
#     "spec": {
#       "addresses": [
#         data.external.kind_network_inspect.result.Subnet
#       ]
#     }
#   }
# }

# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1380#issuecomment-962058148
resource "helm_release" "kind_address_pool" {
  depends_on = [helm_release.metallb]
  name       = "raw"
  repository = "https://helm-charts.wikimedia.org/stable"
  chart      = "raw"
  version    = "0.3.0"
  values = [
    <<-EOF
    resources:
      - apiVersion: metallb.io/v1beta1
        kind: IPAddressPool
        metadata:
          name: main-address
          namespace: ${var.namespace}
        spec:
          addresses:
          - ${cidrsubnet(data.external.kind_network_inspect.result.Subnet, 12, 8)}
    EOF
  ]
}
