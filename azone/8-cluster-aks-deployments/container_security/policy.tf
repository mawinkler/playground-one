# ####################################
# Container Security Policies API
# ####################################
data "restapi_object" "policies" {
  provider     = restapi.container_security
  path         = "/beta/containerSecurity/policies"
  search_key   = "name"
  search_value = var.cluster_policy
  results_key  = "items"
  id_attribute = "id"
}

locals {
  cluster_policy = jsondecode(data.restapi_object.policies.api_response).id
}

output "policy_id" {
  value = local.cluster_policy
}
