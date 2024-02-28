# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "metallb_system_namespace" {
  metadata {
    name = var.namespace
  }
}
