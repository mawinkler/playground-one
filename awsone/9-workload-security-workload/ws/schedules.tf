# ####################################
# Deep Security AntiMalwareConfigurations API
# ####################################
data "restapi_object" "schedule_every_day_all_day" {
  provider     = restapi.wsrest
  path         = "/schedules"
  search_key   = "name"
  search_value = "Every Day All Day"
  results_key  = "schedules"
  id_attribute = "ID"
}

locals {
  schedule_every_day_all_day = jsondecode(data.restapi_object.schedule_every_day_all_day.api_response).ID
}
