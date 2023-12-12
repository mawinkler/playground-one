# ####################################
# Deep Security Policies API
# ####################################
resource "time_static" "unix_time" {
  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}

locals {
  unix_time      = time_static.unix_time.unix
  unix_time_plus = (local.unix_time + 300) * 1000
}

output "unix_time_plus" {
  value = local.unix_time_plus
}

resource "restapi_object" "scheduled_recommendation_scan" {

  provider       = restapi.dsrest
  path           = "/scheduledtasks"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "ID"

  data = <<-EOT
    {
        "name": "Once Only Scan Computers for Recommendations",
        "type": "scan-for-recommendations",
        "scheduleDetails": {
            "timeZone": "UTC",
            "recurrenceType": "none",
            "onceOnlyScheduleParameters": {
                "startTime": ${local.unix_time_plus}
            }
        },
        "enabled": true,
        "nextRunTime": ${local.unix_time_plus},
        "scanForRecommendationsTaskParameters": {
            "computerFilter": {
                "type": "computers-using-policy",
                "policyID": ${local.linux_policy_id}
            }
        }
    }
  EOT

  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}

locals {
  scheduled_recommendation_scan = jsondecode(restapi_object.scheduled_recommendation_scan.api_response).ID
}
