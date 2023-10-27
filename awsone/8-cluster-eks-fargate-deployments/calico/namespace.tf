# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "calico_namespace" {
  metadata {
    name = var.namespace
  }
}
