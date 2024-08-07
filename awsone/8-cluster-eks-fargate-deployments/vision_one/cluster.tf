resource "visionone_container_cluster" "terraform_cluster" {
  provider                   = visionone.container_security
  name                       = replace(var.cluster_name, "-", "_")
  description                = "by Terraform Provider"
  resource_id                = var.cluster_arn
  policy_id                  = local.cluster_policy
  group_id                   = var.group_id
  runtime_security_enabled   = true
  vulnerability_scan_enabled = true
  namespaces                 = ["kube-system"]
  # namespaces                 = ["kube-system", "calico-system", "calico-apiserver", "tigera-operator"]
}

resource "helm_release" "trendmicro" {
  name             = "trendmicro"
  chart            = "https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz"
  namespace        = var.namespace
  create_namespace = true

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
    name  = "cloudOne.inventoryCollection.enabled"
    value = visionone_container_cluster.terraform_cluster.inventory_collection
  }

  # PGO
  set {
    name  = "cloudOne.oversight.syncPeriod"
    value = "600s"
  }
  set {
    name  = "cloudOne.fargateInjector.enabled"
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
