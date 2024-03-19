# ####################################
# Container Security Cluster API
# ####################################
resource "restapi_object" "systemsettings" {

  provider       = restapi.dsrest
  path           = "/systemsettings"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "platformSettingAgentInitiatedActivationEnabled/value"

  data = <<-EOT
    {
      "platformSettingAgentInitiatedActivationEnabled": { "value": "For any computers" },
      "platformSettingWindowsUpgradeOnActivationEnabled": { "value": "true" },
      "platformSettingLinuxUpgradeOnActivationEnabled": { "value": "true" },
      "platformSettingApiSoapWebServiceEnabled": { "value": "true" }
    }
  EOT

  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}
