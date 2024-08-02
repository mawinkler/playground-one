# ####################################
# Istio CNI
# ####################################
# This will deploy an istio-cni DaemonSet into the cluster, which will create one Pod on
# every active node, deploy the Istio CNI plugin binary on each, and set up the necessary
# node-level configuration for the plugin. The CNI DaemonSet runs with system-node-critical
# PriorityClass. This is because it is the only means of actually reconfiguring pod
# networking to add them to the Istio mesh.
#
# https://istio.io/latest/docs/setup/additional-setup/cni/#installing-the-cni-node-agent
resource "helm_release" "istio_cni" {
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "cni"
  name             = "istio-cni"
  namespace        = var.namespace_base
  create_namespace = true
  version          = "1.22.3"
  wait             = true

  set {
    name  = "global.istioNamespace"
    value = var.namespace_base
  }

  depends_on = [helm_release.istio_base]
}
