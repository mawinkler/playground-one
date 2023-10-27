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
  version      = "v3.26.3"

  # TODO: Prevent calico-node from scheduling on fargate nodes
  set {
    name  = "installation.kubernetesProvider"
    value = "EKS"
  }
}

resource "null_resource" "remove_finalizers" {
  depends_on = [helm_release.calico]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl delete installations.operator.tigera.io default
    EOT
  }

  triggers = {
    helm_tigera = helm_release.calico.status
  }
}
