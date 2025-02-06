# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "argocd_namespace" {
  metadata {
    name = var.namespace
  }
}
