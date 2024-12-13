# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "pgoweb_namespace" {
  metadata {
    name = var.namespace
  }
}
