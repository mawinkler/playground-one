# ####################################
# Locals
# ####################################
# Get the cluster id from inventory
data "restapi_object" "cluster" {
  depends_on   = [restapi_object.cluster]
  provider     = restapi.container_security
  path         = "/beta/containerSecurity/kubernetesClusters"
  results_key  = "items"
  search_key   = "name"
  search_value = local.cluster_name
}

locals {
  cluster_id       = jsondecode(data.restapi_object.cluster.api_response).id
  cluster_apikey   = jsondecode(restapi_object.cluster.api_response).apiKey
  cluster_endpoint = jsondecode(restapi_object.cluster.api_response).endpointUrl
  cluster_policy   = jsondecode(data.restapi_object.policies.api_response).id
  cluster_name     = replace("${var.environment}-${random_string.suffix.result}", "-", "_")
}
