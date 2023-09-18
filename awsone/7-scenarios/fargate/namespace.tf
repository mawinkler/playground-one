# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "fargate_namespace" {
  metadata {
    name = var.namespace
  }
}
