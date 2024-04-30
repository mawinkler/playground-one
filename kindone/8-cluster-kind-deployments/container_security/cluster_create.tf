# ####################################
# Container Security Life-cycle
# ####################################
resource "helm_release" "container_security" {
  depends_on   = [kubernetes_namespace_v1.trendmicro_system]
  chart        = "https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz"
  # chart        = "${path.module}/../../../.packages/cloudone-container-security-helm-master"
  name         = "container-security"
  namespace    = var.namespace
  reuse_values = true

  set {
    name  = "cloudOne.apiKey"
    value = local.cluster_apikey
  }

  set {
    name  = "cloudOne.exclusion.namespaces"
    value = "{calico-system,calico-apiserver,tigera-operator,local-path-storage,kube-system}"
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

  # set {
  #   name  = "cloudOne.runtimeSecurity.customRules.enabled"
  #   value = true
  # }

  # set {
  #   name  = "cloudOne.runtimeSecurity.customRules.output.json"
  #   value = true
  # }

  set {
    name  = "cloudOne.vulnerabilityScanning.enabled"
    value = true
  }

  set {
    name  = "cloudOne.fargateInjector.enabled"
    value = false
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

  # set {
  #   name  = "proxy.httpsProxy"
  #   value = "http://192.168.1.122:3128"
  # }

  # set {
  #   name  = "proxy.httpProxy"
  #   value = "http://192.168.1.122:3128"
  # }

  lifecycle {
    ignore_changes = [
      set,
    ]
  }
}
