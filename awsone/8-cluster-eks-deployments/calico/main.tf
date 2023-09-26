# ####################################
# Calico Life-cycle
# ####################################
resource "helm_release" "calico" {
  depends_on   = [kubernetes_namespace_v1.calico_namespace]
  repository   = "https://docs.tigera.io/calico/charts"
  chart        = "tigera-operator"
  name         = "projectcalico"
  namespace    = var.namespace
  reuse_values = true

  set {
    name  = "installation.kubernetesProvider"
    value = "EKS"
  }
}
# --version v3.25.0
