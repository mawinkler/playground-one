# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "goat_namespace" {
  metadata {
    name = var.namespace
  }
}
