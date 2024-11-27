# ####################################
# Container Security Policies API
# ####################################
data "restapi_object" "policies" {
  provider     = restapi.container_security
  path         = "/v3.0/containerSecurity/policies"
  search_key   = "name"
  search_value = var.cluster_policy
  results_key  = "items"
  id_attribute = "id"
}
