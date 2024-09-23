# ####################################
# Deep Security Stateful Inspection API
# ####################################
data "restapi_object" "stateful_inspection" {
  provider     = restapi.wsrest
  path         = "/statefulconfigurations"
  search_key   = "name"
  search_value = "Enable Stateful Inspection"
  results_key  = "statefulConfigurations"
  id_attribute = "ID"
}

locals {
  stateful_inspection = jsondecode(data.restapi_object.stateful_inspection.api_response).ID
}
