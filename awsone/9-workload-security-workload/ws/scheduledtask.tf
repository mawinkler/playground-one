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
  unix_time_plus_300 = (local.unix_time + 300) * 1000
  unix_time_plus_450 = (local.unix_time + 450) * 1000
}

resource "restapi_object" "scheduled_recommendation_scan_linux" {

  provider       = restapi.wsrest
  path           = "/scheduledtasks"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "ID"

  data = <<-EOT
    {
        "name": "Once Only Scan Linux Computers for Recommendations",
        "type": "scan-for-recommendations",
        "scheduleDetails": {
            "timeZone": "UTC",
            "recurrenceType": "none",
            "onceOnlyScheduleParameters": {
                "startTime": ${local.unix_time_plus_300}
            }
        },
        "enabled": true,
        "nextRunTime": ${local.unix_time_plus_300},
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

resource "restapi_object" "scheduled_recommendation_scan_windows" {

  provider       = restapi.wsrest
  path           = "/scheduledtasks"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "ID"

  data = <<-EOT
    {
        "name": "Once Only Scan Windows Computers for Recommendations",
        "type": "scan-for-recommendations",
        "scheduleDetails": {
            "timeZone": "UTC",
            "recurrenceType": "none",
            "onceOnlyScheduleParameters": {
                "startTime": ${local.unix_time_plus_450}
            }
        },
        "enabled": true,
        "nextRunTime": ${local.unix_time_plus_450},
        "scanForRecommendationsTaskParameters": {
            "computerFilter": {
                "type": "computers-using-policy",
                "policyID": ${local.windows_policy_id}
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
