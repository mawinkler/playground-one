# ####################################
# Container Security Cluster API
# ####################################
resource "restapi_object" "cluster" {
  provider       = restapi.container_security
  path           = "/v3.0/containerSecurity/kubernetesClusters"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "name"
  data           = <<-EOT
    {
      "name": "${replace(var.cluster_name, "-", "_")}",
      "description": "Playground Cluster",
      "policyID": "${local.cluster_policy}",
      "resourceId": "${var.cluster_arn}",
      "groupId": "${var.group_id}"
    }
  EOT
}
