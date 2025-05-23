resource "visionone_container_cluster" "terraform_cluster" {
  provider                   = visionone.container_security
  name                       = replace(var.cluster_name, "-", "_")
  description                = "PlaygroundOne"
  policy_id                  = local.cluster_policy
  group_id                   = var.group_id
  runtime_security_enabled   = true
  vulnerability_scan_enabled = true
  malware_scan_enabled       = true
  namespaces                 = ["kube-system", "trendmicro-system"]
  # namespaces                 = ["kube-system", "calico-system", "calico-apiserver", "tigera-operator"]
}

resource "helm_release" "trendmicro" {
  name             = "trendmicro-system"
  chart            = "https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz"
  namespace        = var.namespace
  create_namespace = true
  wait             = false
  timeout          = 600

  set {
    name  = "cloudOne.apiKey"
    value = visionone_container_cluster.terraform_cluster.api_key
  }
  set {
    name  = "cloudOne.endpoint"
    value = visionone_container_cluster.terraform_cluster.endpoint
  }
  set_list {
    name  = "cloudOne.exclusion.namespaces"
    value = visionone_container_cluster.terraform_cluster.namespaces
  }
  set {
    name  = "cloudOne.runtimeSecurity.enabled"
    value = visionone_container_cluster.terraform_cluster.runtime_security_enabled
  }
  set {
    name  = "cloudOne.vulnerabilityScanning.enabled"
    value = visionone_container_cluster.terraform_cluster.vulnerability_scan_enabled
  }
  set {
    name  = "cloudOne.malwareScanning.enabled"
    value = visionone_container_cluster.terraform_cluster.malware_scan_enabled
  }
  set {
    name  = "cloudOne.inventoryCollection.enabled"
    value = visionone_container_cluster.terraform_cluster.inventory_collection
  }

  set {
    name  = "replicas.admissionController"
    value = 2
  }

  # PGO
  set {
    name  = "cloudOne.policyOperator.enabled"
    value = var.cluster_policy_operator
  }

  set {
    name  = "cloudOne.policyOperator.clusterPolicyName"
    value = "pgo-cluster-policy"
  }

  set {
    name  = "cloudOne.oversight.syncPeriod"
    value = "600s"
  }
  set {
    name  = "cloudOne.fargateInjector.enabled"
    value = false
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

  # # Malware Scanning
  # set {
  #   name  = "malwareScanning.scanner.autoscaling.enabled"
  #   value = true
  # }
  # set {
  #   name  = "malwareScanning.scanTimeoutSeconds"
  #   value = 300
  # }
  # set {
  #   name  = "malwareScanning.scanner.autoscaling.minReplicas"
  #   value = 1
  # }
  # set {
  #   name  = "malwareScanning.scanner.autoscaling.maxReplicas"
  #   value = 2  # depends on the number compute nodes in cluster
  # }
  # set {
  #   name  = "malwareScanning.scanner.autoscaling.targetCPUUtilization"
  #   value = 800
  # }
  # set {
  #   name  = "scanManager.maxJobCount"
  #   value = 4
  # }
  # set {
  #   name  = "scanManager.activeDeadlineSeconds"
  #   value = 3600
  # }
  set {
    name  = "resources.scanner.limits.memory"
    value = "1024Mi"
  }
}
