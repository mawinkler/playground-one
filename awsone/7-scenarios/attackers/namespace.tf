# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "attackers_namespace" {
  metadata {
    name = var.namespace
  }
}
