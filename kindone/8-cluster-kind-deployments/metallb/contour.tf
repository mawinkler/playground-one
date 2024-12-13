# #############################################################################
# Deploy Contour
# #############################################################################
resource "helm_release" "projectcontour" {
  # https://artifacthub.io/packages/helm/bitnami/contour
  depends_on = [helm_release.metallb, helm_release.kind_address_pool]

  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "contour"
  name             = "contour"
  namespace        = "projectcontour"
  version          = local.contour_cersion
  create_namespace = true
}
