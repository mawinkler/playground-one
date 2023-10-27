# ####################################
# Container Security Life-cycle
# ####################################
resource "helm_release" "container_security" {
  depends_on   = [kubernetes_namespace_v1.trendmicro_system]
  chart        = "https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz"
  name         = "container-security"
  namespace    = var.namespace
  reuse_values = true

  set {
    name  = "cloudOne.apiKey"
    value = local.cluster_apikey
  }

  set {
    name  = "cloudOne.exclusion.namespaces"
    value = "kube-system, calico-system"
  }

  set {
    name  = "cloudOne.endpoint"
    value = "https://container.${var.cloud_one_region}.${var.cloud_one_instance}.trendmicro.com"
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
