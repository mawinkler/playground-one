# ####################################
# Container Security Life-cycle
# ####################################
resource "helm_release" "container_security" {
  depends_on   = [kubernetes_namespace_v1.trendmicro_system]
  chart        = "https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz"
  name         = "container-security"
  namespace    = var.namespace
  reuse_values = true
  wait         = false
  timeout      = 600

  set {
    name  = "cloudOne.apiKey"
    value = local.cluster_apikey
  }

  set {
    name  = "cloudOne.exclusion.namespaces"
    value = "{calico-system,calico-apiserver,tigera-operator,kube-system,trendmicro-system}"
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
    name  = "cloudOne.malwareScanning.enabled"
    value = true
  }

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
  #   name  = "securityContext.scout.falco.privileged"
  #   value = false
  # }
  # set {
  #   name  = "securityContext.scout.falco.capabilities.drop"
  #   value = "ALL"
  # }
  # set {
  #   name  = "securityContext.scout.falco.capabilities.add"
  #   value = "{sys_admin,sys_resource,sys_ptrace}"
  # }


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
