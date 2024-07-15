# ####################################
# Locals
# ####################################
locals {
  cluster_policy   = jsondecode(data.restapi_object.policies.api_response).id
}
