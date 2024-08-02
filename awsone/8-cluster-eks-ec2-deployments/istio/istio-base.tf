# ####################################
# Istio base
# ####################################
# Install the Istio base chart which contains cluster-wide Custom Resource Definitions (CRDs) 
# which must be installed prior to the deployment of the Istio control plane
# When performing a revisioned installation, the base chart requires the
# --set defaultRevision=<revision> value to be set for resource validation to function. 
# Below we install the default revision, so --set defaultRevision=default is configured.
#
# https://istio.io/latest/docs/setup/install/helm/#installation-steps
resource "helm_release" "istio_base" {
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  name             = "istio-base"
  namespace        = var.namespace_base
  create_namespace = true
  version          = "1.22.3"

  set {
    name  = "global.istioNamespace"
    value = var.namespace_base
  }

  set {
    name  = "defaultRevision"
    value = "default"
  }
}
