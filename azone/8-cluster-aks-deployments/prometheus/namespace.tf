# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "prometheus_namespace" {
  metadata {
    name = var.namespace
  }
}
