# ####################################
# Container Security Cluster API
# ####################################
resource "null_resource" "always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}

resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "restapi_object" "cluster" {

  provider       = restapi.container_security
  path           = "/beta/containerSecurity/kubernetesClusters"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "name"
  data           = <<-EOT
    {
      "name": "${replace(var.cluster_name, "-", "_")}",
      "description": "Playground Cluster",
      "policyID": "${local.cluster_policy}",
      "arn": "${var.cluster_arn}"
    }
  EOT

  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}

# Store Cluster API Key and endpoint for use in the helm installation step
locals {
  cluster_apikey   = jsondecode(restapi_object.cluster.api_response).apiKey
  cluster_endpoint = jsondecode(restapi_object.cluster.api_response).endpointUrl
}
