# ####################################
# Container Security Life-cycle
# ####################################
resource "helm_release" "container_security" {
  depends_on   = [kubernetes_namespace_v1.trendmicro_system]
  chart        = "https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz"
  name         = "container-security"
  namespace    = var.namespace
  reuse_values = true

  # cloudOne: 
  #     apiKey: 2Zi...
  #     endpoint: https://container.us-1.cloudone.trendmicro.com
  #     exclusion: 
  #         namespaces: [calico-system, kube-system]
  #     runtimeSecurity:
  #         enabled: true
  #     vulnerabilityScanning:
  #         enabled: true
  #     inventoryCollection:
  #         enabled: true

  set {
    name  = "cloudOne.apiKey"
    value = local.cluster_apikey
  }

  set {
    name  = "cloudOne.exclusion.namespaces"
    value = "{calico-system,calico-apiserver,tigera-operator,kube-system}"
  }

  set {
    name  = "cloudOne.endpoint"
    value = local.cluster_endpoint
  }

  set {
    name  = "cloudOne.admissionController.enabled"
    value = true
  }

  set {
    name  = "cloudOne.oversight.enabled"
    value = true
  }

  set {
    name  = "cloudOne.oversight.syncPeriod"
    value = "600s"
  }

  set {
    name  = "cloudOne.runtimeSecurity.enabled"
    value = true
  }

  set {
    name  = "cloudOne.vulnerabilityScanning.enabled"
    value = true
  }

  set {
    name  = "cloudOne.fargateInjector.enabled"
    value = true
  }

  set {
    name  = "cloudOne.inventoryCollection.enabled"
    value = true
  }

  set {
    name  = "networkPolicy.enabled"
    value = true
  }

  set {
    name  = "telemetry.enabled"
    value = true
  }

  set {
    name  = "securityContext.enabled"
    value = true
  }
}
