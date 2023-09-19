# #############################################################################
# Create a Namespace
# #############################################################################
resource "kubernetes_namespace_v1" "fargate_namespace" {
  count = var.create_fargate_profile ? 1 : 0
  
  metadata {
    name = "fargate"
  }
}
