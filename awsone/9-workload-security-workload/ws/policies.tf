# ####################################
# Deep Security Policies API
# ####################################
resource "restapi_object" "linux_policy" {

  provider       = restapi.wsrest
  path           = "/policies"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "ID"

  data = <<-EOT
    {
      "parentID": 1,
      "name": "Playground One Linux Server",
      "description": "Demo Policy for the Playground One Linux computers.",
      "policySettings": {
        "firewallSettingFailureResponseEngineSystem": {
            "value": "Fail open"
        },
        "integrityMonitoringSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "intrusionPreventionSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "logInspectionSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "platformSettingAutoAssignNewIntrusionPreventionRulesEnabled": {
            "value": "true"
        },
        "antiMalwareSettingEnableUserTriggerOnDemandScan": {
          "value": "true"
        }
      },
      "recommendationScanMode": "off",
      "autoRequiresUpdate": "on",
      "antiMalware": {
        "state": "on",
        "realTimeScanConfigurationID": ${local.anti_malware_advanced_rtscan},
        "realTimeScanScheduleID": ${local.schedule_every_day_all_day},
        "manualScanConfigurationID": ${local.anti_malware_manual_scan},
        "scheduledScanConfigurationID": ${local.anti_malware_scheduled_scan},
        "realTimeScanDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "realTimeScanExcludedDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "realTimeScanFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "realTimeScanExcludedFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "realTimeScanExcludedFileSetting": {
          "lists": [],
          "inherited": false,
          "fileLists": []
        },
        "manualScanDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "manualScanExcludedDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "manualScanFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "manualScanExcludedFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "manualExcludedScanFileSetting": {
          "lists": [],
          "inherited": false,
          "fileLists": []
        },
        "scheduledScanDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "scheduledScanExcludedDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "scheduledScanFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "scheduledScanExcludedFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "scheduledScanExcludedFileSetting": {
          "lists": [],
          "inherited": false,
          "fileLists": []
        }
      },
      "webReputation": {
        "state": "on"
      },
      "deviceControl": {
        "state": "off"
      },
      "activityMonitoring": {
        "state": "off"
      },
      "firewall": {
        "state": "on",
        "globalStatefulConfigurationID": ${local.stateful_inspection},
        "ruleIDs": [
          ${local.firewall_rule_allow_icmp_fragmentation_packet},
          ${local.firewall_rule_allow_solicited_icmp_replies},
          ${local.firewall_rule_allow_solicited_tcpudp_replies},
          ${local.firewall_rule_arp},
          ${local.firewall_rule_dhcp_server},
          ${local.firewall_rule_dns_server},
          ${local.firewall_rule_icmp_echo_request},
          ${local.firewall_rule_ident},
          ${local.firewall_rule_netbios_name_service},
          ${local.firewall_rule_web_remote_access_ssh},
          ${local.firewall_rule_web_server}
        ]
      },
      "intrusionPrevention": {
        "state": "prevent"
      },
      "integrityMonitoring": {
        "state": "real-time"
      },
      "logInspection": {
        "state": "on"
      },
      "applicationControl": {
        "state": "off",
        "trustRulesetID": "0"
      }
    }
  EOT

#   lifecycle {
#     replace_triggered_by = [
#       null_resource.always_run
#     ]
#   }
}

resource "restapi_object" "windows_policy" {

  provider       = restapi.wsrest
  path           = "/policies"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "ID"

  data = <<-EOT
    {
      "parentID": 1,
      "name": "Playground One Windows Server",
      "description": "Demo Policy for the Playground One Windows computers.",
      "policySettings": {
        "firewallSettingFailureResponseEngineSystem": {
            "value": "Fail open"
        },
        "integrityMonitoringSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "intrusionPreventionSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "logInspectionSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "platformSettingAutoAssignNewIntrusionPreventionRulesEnabled": {
            "value": "true"
        },
        "antiMalwareSettingEnableUserTriggerOnDemandScan": {
          "value": "true"
        }
      },
      "recommendationScanMode": "off",
      "autoRequiresUpdate": "on",
      "antiMalware": {
        "state": "on",
        "realTimeScanConfigurationID": ${local.anti_malware_advanced_rtscan},
        "realTimeScanScheduleID": ${local.schedule_every_day_all_day},
        "manualScanConfigurationID": ${local.anti_malware_manual_scan},
        "scheduledScanConfigurationID": ${local.anti_malware_scheduled_scan},
        "realTimeScanDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "realTimeScanExcludedDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "realTimeScanFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "realTimeScanExcludedFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "realTimeScanExcludedFileSetting": {
          "lists": [],
          "inherited": false,
          "fileLists": []
        },
        "manualScanDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "manualScanExcludedDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "manualScanFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "manualScanExcludedFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "manualExcludedScanFileSetting": {
          "lists": [],
          "inherited": false,
          "fileLists": []
        },
        "scheduledScanDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "scheduledScanExcludedDirectorySetting": {
          "lists": [],
          "inherited": false,
          "directoryLists": []
        },
        "scheduledScanFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "scheduledScanExcludedFileExtensionSetting": {
          "lists": [],
          "inherited": false,
          "fileExtensionLists": []
        },
        "scheduledScanExcludedFileSetting": {
          "lists": [],
          "inherited": false,
          "fileLists": []
        }
      },
      "webReputation": {
        "state": "on"
      },
      "deviceControl": {
        "state": "off"
      },
      "activityMonitoring": {
        "state": "off"
      },
      "firewall": {
        "state": "on",
        "globalStatefulConfigurationID": ${local.stateful_inspection},
        "ruleIDs": [
          ${local.firewall_rule_allow_icmp_fragmentation_packet},
          ${local.firewall_rule_allow_solicited_icmp_replies},
          ${local.firewall_rule_allow_solicited_tcpudp_replies},
          ${local.firewall_rule_arp},
          ${local.firewall_rule_dhcp_server},
          ${local.firewall_rule_dns_server},
          ${local.firewall_rule_icmp_echo_request},
          ${local.firewall_rule_ident},
          ${local.firewall_rule_netbios_name_service},
          ${local.firewall_rule_web_remote_access_ssh},
          ${local.firewall_rule_web_server}
        ]
      },
      "intrusionPrevention": {
        "state": "prevent"
      },
      "integrityMonitoring": {
        "state": "real-time"
      },
      "logInspection": {
        "state": "on"
      },
      "applicationControl": {
        "state": "off",
        "trustRulesetID": "0"
      }
    }
  EOT

#   lifecycle {
#     replace_triggered_by = [
#       null_resource.always_run
#     ]
#   }
}

locals {
  linux_policy_id = jsondecode(restapi_object.linux_policy.api_response).ID
  windows_policy_id = jsondecode(restapi_object.windows_policy.api_response).ID
}
