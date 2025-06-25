# ####################################
# Container Security Life-cycle
# ####################################
# visionOne: 
#     bootstrapToken: <TOKEN>
#     endpoint: https://api.xdr.trendmicro.com/external/v2/direct/vcs/external/vcs
#     exclusion: 
#         namespaces: [calico-system, kube-system]
#     runtimeSecurity:
#         enabled: true
#     vulnerabilityScanning:
#         enabled: true
#     malwareScanning:
#         enabled: true
#     secretScanning:
#         enabled: true
#     inventoryCollection:
#         enabled: true
#
# helm install \
#     trendmicro \
#     --namespace trendmicro-system --create-namespace \
#     --values overrides.yaml \
#     https://github.com/trendmicro/visionone-container-security-helm/archive/main.tar.gz
resource "helm_release" "container_security" {
  depends_on   = [kubernetes_namespace_v1.trendmicro_system]
  chart        = "https://github.com/trendmicro/visionone-container-security-helm/archive/main.tar.gz"
  name         = "container-security"
  namespace    = var.namespace
  reuse_values = true
  wait         = false
  timeout      = 600

  # set {
  #   name  = "visionOne.bootstrapToken"
  #   value = local.cluster_apikey
  # }

  set {
    name  = "visionOne.clusterRegistrationKey"
    value = true
  }

  set {
    name  = "visionOne.groupId"
    value = var.group_id
  }

  set {
    name  = "visionOne.clusterName"
    value = replace("${var.environment}-${random_string.suffix.result}", "-", "_")
  }

  set {
    name  = "visionOne.policyId"
    value = local.cluster_policy
  }

  set {
    name  = "visionOne.exclusion.namespaces"
    value = "{calico-system,calico-apiserver,tigera-operator,local-path-storage,kube-system,trendmicro-system}"
  }

  # set {
  #   name  = "visionOne.endpoint"
  #   value = local.cluster_endpoint
  # }

  set {
    name  = "visionOne.oversight.syncPeriod"
    value = "600s"
  }

  set {
    name  = "visionOne.runtimeSecurity.enabled"
    value = true
  }

  set {
    name  = "visionOne.vulnerabilityScanning.enabled"
    value = true
  }

  set {
    name  = "visionOne.malwareScanning.enabled"
    value = true
  }

  set {
    name  = "visionOne.secretScanning.enabled"
    value = true
  }

  set {
    name  = "visionOne.inventoryCollection.enabled"
    value = true
  }

  # set {
  #   name  = "visionOne.policyOperator.enabled"
  #   value = true
  # }

  # set {
  #   name  = "visionOne.policyOperator.clusterPolicyName"
  #   value = "trendmicro-cluster-policy"
  # }

  set {
    name  = "visionOne.fargateInjector.enabled"
    value = false
  }

  # set {
  #   name  = "networkPolicy.enabled"
  #   value = true
  # }

  # set {
  #   name  = "telemetry.enabled"
  #   value = true
  # }

  # set {
  #   name  = "securityContext.enabled"
  #   value = true
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
