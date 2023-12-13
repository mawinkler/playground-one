# ####################################
# Deep Security Policies API
# ####################################
resource "restapi_object" "linux_policy" {

  provider       = restapi.dsrest
  path           = "/policies"
  create_method  = "POST"
  destroy_method = "DELETE"
  id_attribute   = "ID"

  data = <<-EOT
    {
      "parentID": 1,
      "name": "Playground One Linux Server",
      "description": "Demo Policy for the Playground One Linux computers. This policy has all security modules enabled.",
      "policySettings": {
        "logInspectionSettingSeverityClippingAgentEventSendSyslogLevelMin": {
            "value": "Medium (6)"
        },
        "firewallSettingEngineOptionConnectionsCleanupMax": {
            "value": "1000"
        },
        "firewallSettingEngineOptionVerifyTcpChecksumEnabled": {
            "value": "false"
        },
        "antiMalwareSettingScanCacheOnDemandConfigId": {
            "value": "1"
        },
        "applicationControlSettingSharedRulesetId": {
            "value": "0"
        },
        "webReputationSettingSmartProtectionServerConnectionLostWarningEnabled": {
            "value": "true"
        },
        "applicationControlSettingExecutionEnforcementLevel": {
            "value": "Allow unrecognized software until it is explicitly blocked"
        },
        "webReputationSettingBlockedUrlDomains": {
            "value": ""
        },
        "firewallSettingEngineOptionSynSentTimeout": {
            "value": "20 Seconds"
        },
        "platformSettingAgentSelfProtectionPassword": {
            "value": ""
        },
        "firewallSettingReconnaissanceBlockTcpXmasAttackDuration": {
            "value": "No"
        },
        "intrusionPreventionSettingVirtualAndContainerNetworkScanEnabled": {
            "value": "false"
        },
        "logInspectionSettingSyslogConfigId": {
            "value": "0"
        },
        "firewallSettingEngineOptionDebugModeEnabled": {
            "value": "false"
        },
        "firewallSettingVirtualAndContainerNetworkScanEnabled": {
            "value": "false"
        },
        "antiMalwareSettingFileHashSha256Enabled": {
            "value": "false"
        },
        "firewallSettingReconnaissanceNotifyFingerprintProbeEnabled": {
            "value": "true"
        },
        "firewallSettingEventLogFileRetainNum": {
            "value": "3"
        },
        "firewallSettingAntiEvasionCheckTcpPawsZero": {
            "value": "Allow"
        },
        "antiMalwareSettingConnectedThreatDefenseUseControlManagerSuspiciousObjectListEnabled": {
            "value": "true"
        },
        "intrusionPreventionSettingEngineOptionFragmentedIpKeepMax": {
            "value": "1000"
        },
        "firewallSettingEngineOptionDrop6To4BogonsAddressesEnabled": {
            "value": "true"
        },
        "logInspectionSettingSeverityClippingAgentEventStoreLevelMin": {
            "value": "Medium (6)"
        },
        "platformSettingScanCacheConcurrencyMax": {
            "value": "1"
        },
        "antiMalwareSettingSyslogConfigId": {
            "value": "0"
        },
        "firewallSettingAntiEvasionTcpPawsWindowPolicy": {
            "value": "0"
        },
        "firewallSettingReconnaissanceDetectTcpXmasAttackEnabled": {
            "value": "true"
        },
        "applicationControlSettingRulesetMode": {
            "value": "Use local ruleset"
        },
        "antiMalwareSettingSmartProtectionGlobalServerUseProxyEnabled": {
            "value": "false"
        },
        "webReputationSettingSmartProtectionLocalServerAllowOffDomainGlobal": {
            "value": "false"
        },
        "integrityMonitoringSettingCombinedModeProtectionSource": {
            "value": "Appliance preferred"
        },
        "firewallSettingEngineOptionCloseWaitTimeout": {
            "value": "2 Minutes"
        },
        "platformSettingScanOpenPortListId": {
            "value": "1-1024"
        },
        "platformSettingAgentSelfProtectionPasswordEnabled": {
            "value": "false"
        },
        "firewallSettingEngineOptionAckTimeout": {
            "value": "1 Second"
        },
        "firewallSettingEventLogFileCachedEntriesStaleTime": {
            "value": "15 Minutes"
        },
        "firewallSettingCombinedModeProtectionSource": {
            "value": "Agent preferred"
        },
        "platformSettingAgentEventsSendInterval": {
            "value": "60 Seconds"
        },
        "platformSettingInactiveAgentCleanupOverrideEnabled": {
            "value": "false"
        },
        "firewallSettingFailureResponseEngineSystem": {
            "value": "Fail open"
        },
        "platformSettingRelayState": {
            "value": "false"
        },
        "activityMonitoringSettingIndicatorEnabled": {
            "value": "Off"
        },
        "intrusionPreventionSettingEngineOptionFragmentedIpTimeout": {
            "value": "60 Seconds"
        },
        "firewallSettingAntiEvasionCheckTcpZeroFlags": {
            "value": "Deny"
        },
        "webReputationSettingSmartProtectionGlobalServerUseProxyEnabled": {
            "value": "false"
        },
        "intrusionPreventionSettingNsxSecurityTaggingPreventModeLevel": {
            "value": "No Tagging"
        },
        "firewallSettingReconnaissanceNotifyTcpXmasAttackEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionUdpTimeout": {
            "value": "20 Seconds"
        },
        "webReputationSettingSmartProtectionLocalServerEnabled": {
            "value": "false"
        },
        "firewallSettingEngineOptionTcpMssLimit": {
            "value": "128 Bytes"
        },
        "firewallSettingEngineOptionColdStartTimeout": {
            "value": "5 Minutes"
        },
        "firewallSettingEngineOptionEstablishedTimeout": {
            "value": "3 Hours"
        },
        "antiMalwareSettingIdentifiedFilesSpaceMaxMbytes": {
            "value": "1024"
        },
        "firewallSettingEngineOptionAllowNullIpEnabled": {
            "value": "true"
        },
        "platformSettingNotificationsSuppressPopupsEnabled": {
            "value": "false"
        },
        "firewallSettingAntiEvasionCheckTcpRstFinFlags": {
            "value": "Deny"
        },
        "firewallSettingEngineOptionDisconnectTimeout": {
            "value": "60 Seconds"
        },
        "firewallSettingEngineOptionCloseTimeout": {
            "value": "0 Seconds"
        },
        "firewallSettingEngineOptionTunnelDepthMaxExceededAction": {
            "value": "Drop"
        },
        "antiMalwareSettingEnableUserTriggerOnDemandScan": {
            "value": "false"
        },
        "firewallSettingReconnaissanceDetectTcpNullScanEnabled": {
            "value": "true"
        },
        "platformSettingSmartProtectionAntiMalwareGlobalServerProxyId": {
            "value": ""
        },
        "firewallSettingEngineOptionFilterIpv4Tunnels": {
            "value": "Disable Detection of IPv4 Tunnels"
        },
        "webReputationSettingSmartProtectionLocalServerUrls": {
            "value": ""
        },
        "firewallSettingEngineOptionLogOnePacketPeriod": {
            "value": "5 Minutes"
        },
        "deviceControlSettingSyslogConfigId": {
            "value": "0"
        },
        "firewallSettingEngineOptionFilterIpv6Tunnels": {
            "value": "Disable Detection of IPv6 Tunnels"
        },
        "firewallSettingAntiEvasionCheckTcpCongestionFlags": {
            "value": "Allow"
        },
        "platformSettingHeartbeatMissedAlertThreshold": {
            "value": "2"
        },
        "intrusionPreventionSettingEngineOptionsEnabled": {
            "value": "false"
        },
        "firewallSettingEngineOptionConnectionsNumUdpMax": {
            "value": "1000000"
        },
        "integrityMonitoringSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "firewallSettingEngineOptionTunnelDepthMax": {
            "value": "1"
        },
        "firewallSettingEngineOptionDropUnknownSslProtocolEnabled": {
            "value": "true"
        },
        "antiMalwareSettingNsxSecurityTaggingValue": {
            "value": "ANTI_VIRUS.VirusFound.threat=medium"
        },
        "intrusionPreventionSettingLogDataRuleFirstMatchEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionLoggingPolicy": {
            "value": "Default"
        },
        "platformSettingTroubleshootingLoggingLevel": {
            "value": "Do Not Override"
        },
        "antiMalwareSettingVirtualApplianceOnDemandScanCacheEntriesMax": {
            "value": "500000"
        },
        "webReputationSettingCombinedModeProtectionSource": {
            "value": "Agent preferred"
        },
        "firewallSettingEngineOptionClosingTimeout": {
            "value": "1 Second"
        },
        "activityMonitoringSettingDetectionMode": {
            "value": "Normal"
        },
        "firewallSettingAntiEvasionCheckPaws": {
            "value": "Ignore"
        },
        "intrusionPreventionSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "firewallSettingReconnaissanceDetectFingerprintProbeEnabled": {
            "value": "true"
        },
        "antiMalwareSettingNsxSecurityTaggingRemoveOnCleanScanEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionLogPacketLengthMax": {
            "value": "1500 Bytes"
        },
        "firewallSettingEngineOptionDropTeredoAnomaliesEnabled": {
            "value": "true"
        },
        "webReputationSettingSecurityLevel": {
            "value": "Medium"
        },
        "firewallSettingEngineOptionDropIpv6SiteLocalAddressesEnabled": {
            "value": "false"
        },
        "activityMonitoringSettingActivityEnabled": {
            "value": "Off"
        },
        "firewallSettingEngineOptionStrictTerodoPortCheckEnabled": {
            "value": "true"
        },
        "platformSettingAutoUpdateTlsInspectionSupportEnabled": {
            "value": "true"
        },
        "webReputationSettingBlockedUrlKeywords": {
            "value": ""
        },
        "webReputationSettingSyslogConfigId": {
            "value": "0"
        },
        "firewallSettingFailureResponsePacketSanityCheck": {
            "value": "Fail closed"
        },
        "firewallSettingNetworkEngineMode": {
            "value": "Inline"
        },
        "firewallSettingEventLogFileSizeMax": {
            "value": "4 MB"
        },
        "antiMalwareSettingMalwareScanMultithreadedProcessingEnabled": {
            "value": "true"
        },
        "firewallSettingReconnaissanceDetectTcpSynFinScanEnabled": {
            "value": "true"
        },
        "platformSettingAutoUpdateKernelPackageEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionDropIpZeroPayloadEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionBlockIpv6Agent8AndEarlierEnabled": {
            "value": "true"
        },
        "intrusionPreventionSettingEngineOptionFragmentedIpPacketSendIcmpEnabled": {
            "value": "true"
        },
        "antiMalwareSettingPredictiveMachineLearningExceptions": {
            "value": ""
        },
        "firewallSettingEngineOptionLogEventsPerSecondMax": {
            "value": "100"
        },
        "firewallSettingEngineOptionSslSessionTime": {
            "value": "24 Hours"
        },
        "antiMalwareSettingBehaviorMonitoringScanExclusionList": {
            "value": ""
        },
        "antiMalwareSettingSmartProtectionGlobalServerEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionLogOnePacketWithinPeriodEnabled": {
            "value": "false"
        },
        "firewallSettingEngineOptionGenerateConnectionEventsIcmpEnabled": {
            "value": "false"
        },
        "platformSettingHeartbeatInactiveVmOfflineAlertEnabled": {
            "value": "false"
        },
        "webReputationSettingSmartProtectionWebReputationGlobalServerProxyId": {
            "value": ""
        },
        "platformSettingNetworkEngineStatusCheck": {
            "value": "Enabled"
        },
        "antiMalwareSettingNsxSecurityTaggingEnabled": {
            "value": "true"
        },
        "firewallSettingAntiEvasionCheckFragmentedPackets": {
            "value": "Allow"
        },
        "firewallSettingEngineOptionConnectionsNumIcmpMax": {
            "value": "10000"
        },
        "firewallSettingAntiEvasionCheckTcpSplitHandshake": {
            "value": "Deny"
        },
        "antiMalwareSettingCombinedModeProtectionSource": {
            "value": "Appliance preferred"
        },
        "firewallSettingEngineOptionEventNodesMax": {
            "value": "20000"
        },
        "webReputationSettingMonitorPortListId": {
            "value": "80,8080,443"
        },
        "applicationControlSettingSyslogConfigId": {
            "value": "0"
        },
        "firewallSettingAntiEvasionCheckOutNoConnection": {
            "value": "Allow"
        },
        "firewallSettingEngineOptionBlockIpv6Agent9AndLaterEnabled": {
            "value": "false"
        },
        "integrityMonitoringSettingVirtualApplianceOptimizationScanCacheEntriesMax": {
            "value": "500000"
        },
        "firewallSettingReconnaissanceNotifyTcpNullScanEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionIgnoreStatusCode1": {
            "value": "None"
        },
        "firewallSettingEngineOptionIgnoreStatusCode0": {
            "value": "None"
        },
        "firewallSettingEngineOptionIgnoreStatusCode2": {
            "value": "None"
        },
        "firewallSettingEngineOptionSslSessionSize": {
            "value": "Low - 2500"
        },
        "antiMalwareSettingScanCacheRealTimeConfigId": {
            "value": "2"
        },
        "platformSettingRecommendationOngoingScansInterval": {
            "value": "7 Days"
        },
        "platformSettingSmartProtectionGlobalServerUseProxyEnabled": {
            "value": "false"
        },
        "firewallSettingInterfaceLimitOneActiveEnabled": {
            "value": "false"
        },
        "firewallSettingAntiEvasionCheckTcpChecksum": {
            "value": "Allow"
        },
        "firewallSettingEngineOptionDropIpv6ExtType0Enabled": {
            "value": "true"
        },
        "antiMalwareSettingScanFileSizeMaxMbytes": {
            "value": "0"
        },
        "firewallSettingEngineOptionGenerateConnectionEventsTcpEnabled": {
            "value": "false"
        },
        "antiMalwareSettingFileHashSizeMaxMbytes": {
            "value": "128"
        },
        "firewallSettingEventLogFileCachedEntriesLifeTime": {
            "value": "30 Minutes"
        },
        "platformSettingSmartProtectionGlobalServerProxyId": {
            "value": ""
        },
        "logInspectionSettingAutoApplyRecommendationsEnabled": {
            "value": "Yes"
        },
        "antiMalwareSettingConnectedThreatDefenseSuspiciousFileDdanSubmissionEnabled": {
            "value": "true"
        },
        "deviceControlSettingDeviceControlUsbStorageDeviceAction": {
            "value": "Full Access"
        },
        "webReputationSettingBlockingPageLink": {
            "value": "http://sitesafety.trendmicro.com/"
        },
        "firewallSettingSyslogConfigId": {
            "value": "0"
        },
        "platformSettingAgentCommunicationsDirection": {
            "value": "Bidirectional"
        },
        "integrityMonitoringSettingScanCacheConfigId": {
            "value": "3"
        },
        "antiMalwareSettingDocumentExploitProtectionRuleExceptions": {
            "value": ""
        },
        "firewallSettingAntiEvasionCheckTcpSynWithData": {
            "value": "Deny"
        },
        "antiMalwareSettingFileHashEnabled": {
            "value": "false"
        },
        "firewallSettingReconnaissanceBlockFingerprintProbeDuration": {
            "value": "No"
        },
        "firewallSettingEngineOptionDropIpv6BogonsAddressesEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionBootStartTimeout": {
            "value": "20 Seconds"
        },
        "firewallSettingEngineOptionConnectionsNumTcpMax": {
            "value": "1000000"
        },
        "firewallSettingAntiEvasionSecurityPosture": {
            "value": "Normal"
        },
        "firewallSettingInterfacePatterns": {
            "value": ""
        },
        "firewallSettingInterfaceIsolationEnabled": {
            "value": "false"
        },
        "antiMalwareSettingVirtualApplianceRealTimeScanCacheEntriesMax": {
            "value": "500000"
        },
        "firewallSettingEventsOutOfAllowedPolicyEnabled": {
            "value": "true"
        },
        "firewallSettingAntiEvasionCheckEvasiveRetransmit": {
            "value": "Allow"
        },
        "firewallSettingEngineOptionIcmpTimeout": {
            "value": "60 Seconds"
        },
        "integrityMonitoringSettingSyslogConfigId": {
            "value": "0"
        },
        "firewallSettingEngineOptionConnectionCleanupTimeout": {
            "value": "10 Seconds"
        },
        "antiMalwareSettingSmartProtectionLocalServerAllowOffDomainGlobal": {
            "value": "false"
        },
        "firewallSettingReconnaissanceNotifyTcpSynFinScanEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionErrorTimeout": {
            "value": "10 Seconds"
        },
        "webReputationSettingAllowedUrls": {
            "value": ""
        },
        "firewallSettingReconnaissanceNotifyNetworkOrPortScanEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionFinWait1Timeout": {
            "value": "2 Minutes"
        },
        "firewallSettingEngineOptionGenerateConnectionEventsUdpEnabled": {
            "value": "false"
        },
        "activityMonitoringSettingSyslogConfigId": {
            "value": "0"
        },
        "firewallSettingAntiEvasionCheckTcpSynRstFlags": {
            "value": "Deny"
        },
        "antiMalwareSettingSpywareApprovedList": {
            "value": ""
        },
        "firewallSettingAntiEvasionCheckTcpUrgentFlags": {
            "value": "Allow"
        },
        "intrusionPreventionSettingNsxSecurityTaggingDetectModeLevel": {
            "value": "No Tagging"
        },
        "intrusionPreventionSettingEngineOptionFragmentedIpUnconcernedMacAddressBypassEnabled": {
            "value": "false"
        },
        "firewallSettingEngineOptionLogAllPacketDataEnabled": {
            "value": "false"
        },
        "firewallSettingAntiEvasionCheckTcpSynFinFlags": {
            "value": "Deny"
        },
        "platformSettingHeartbeatInterval": {
            "value": "1 Minute"
        },
        "firewallSettingEngineOptionFragmentSizeMin": {
            "value": "120"
        },
        "antiMalwareSettingSmartProtectionServerConnectionLostWarningEnabled": {
            "value": "true"
        },
        "firewallSettingReconnaissanceBlockNetworkOrPortScanDuration": {
            "value": "No"
        },
        "integrityMonitoringSettingContentHashAlgorithm": {
            "value": "sha1"
        },
        "antiMalwareSettingSmartScanState": {
            "value": "Automatic"
        },
        "firewallSettingConfigPackageExceedsAlertMaxEnabled": {
            "value": "true"
        },
        "platformSettingEnvironmentVariableOverrides": {
            "value": ""
        },
        "firewallSettingEngineOptionFragmentOffsetMin": {
            "value": "60"
        },
        "antiMalwareSettingSmartProtectionLocalServerUrls": {
            "value": ""
        },
        "firewallSettingEngineOptionSynRcvdTimeout": {
            "value": "60 Seconds"
        },
        "firewallSettingEventLogFileCachedEntriesNum": {
            "value": "128"
        },
        "firewallSettingEngineOptionForceAllowIcmpType3Code4": {
            "value": "Add Force Allow rule for ICMP type3 code4"
        },
        "firewallSettingReconnaissanceBlockTcpNullScanDuration": {
            "value": "No"
        },
        "platformSettingSmartProtectionGlobalServerEnabled": {
            "value": "true"
        },
        "integrityMonitoringSettingRealtimeEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionLastAckTimeout": {
            "value": "30 Seconds"
        },
        "deviceControlSettingDeviceControlAutoRunUsbAction": {
            "value": "Allow"
        },
        "firewallSettingReconnaissanceExcludeIpListId": {
            "value": "1"
        },
        "deviceControlSettingDeviceControlEnabled": {
            "value": "Off"
        },
        "platformSettingAgentSelfProtectionEnabled": {
            "value": "false"
        },
        "firewallSettingEngineOptionDropIpv6ReservedAddressesEnabled": {
            "value": "true"
        },
        "firewallSettingAntiEvasionCheckFinNoConnection": {
            "value": "Allow"
        },
        "firewallSettingEngineOptionDebugPacketNumMax": {
            "value": "8"
        },
        "firewallSettingEngineOptionBypassCiscoWaasConnectionsEnabled": {
            "value": "false"
        },
        "firewallSettingReconnaissanceEnabled": {
            "value": "true"
        },
        "platformSettingHeartbeatLocalTimeShiftAlertThreshold": {
            "value": "Unlimited"
        },
        "antiMalwareSettingFileHashMd5Enabled": {
            "value": "false"
        },
        "firewallSettingReconnaissanceDetectNetworkOrPortScanEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionSilentTcpConnectionDropEnabled": {
            "value": "false"
        },
        "firewallSettingEngineOptionBlockSameSrcDstIpEnabled": {
            "value": "true"
        },
        "firewallSettingEngineOptionForceAllowDhcpDns": {
            "value": "Allow DNS Query and DHCP Client"
        },
        "firewallSettingReconnaissanceIncludeIpListId": {
            "value": ""
        },
        "firewallSettingEngineOptionsEnabled": {
            "value": "false"
        },
        "firewallSettingReconnaissanceBlockTcpSynFinScanDuration": {
            "value": "No"
        },
        "webReputationSettingSecurityBlockUntestedPagesEnabled": {
            "value": "false"
        },
        "webReputationSettingAllowedUrlDomains": {
            "value": ""
        },
        "platformSettingEnableContainerFileOnAccessScan": {
            "value": "true"
        },
        "antiMalwareSettingTrustedCertificateExceptionEnabled": {
            "value": "false"
        },
        "firewallSettingEventLogFileIgnoreSourceIpListId": {
            "value": ""
        },
        "firewallSettingEngineOptionDropIpv6FragmentsLowerThanMinMtuEnabled": {
            "value": "true"
        },
        "platformSettingAutoAssignNewIntrusionPreventionRulesEnabled": {
            "value": "true"
        },
        "firewallSettingAntiEvasionCheckRstNoConnection": {
            "value": "Allow"
        },
        "webReputationSettingBlockedUrls": {
            "value": ""
        },
        "platformSettingCombinedModeNetworkGroupProtectionSource": {
            "value": "Agent preferred"
        },
        "webReputationSettingAlertingEnabled": {
            "value": "false"
        },
        "antiMalwareSettingNsxSecurityTaggingOnRemediationFailureEnabled": {
            "value": "true"
        },
        "integrityMonitoringSettingCpuUsageLevel": {
            "value": "High"
        },
        "platformSettingAutoUpdateAntiMalwareEngineEnabled": {
            "value": "false"
        },
        "deviceControlSettingDeviceControlMobileDeviceAction": {
            "value": "Full Access"
        },
        "intrusionPreventionSettingInspectTlsTrafficEnabled": {
            "value": "true"
        },
        "intrusionPreventionSettingCombinedModeProtectionSource": {
            "value": "Agent preferred"
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
          1,
          2,
          5,
          6,
          7,
          9,
          11,
          19,
          20,
          23,
          24,
          25,
          26,
          30,
          31,
          34,
          72
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

  lifecycle {
    replace_triggered_by = [
      null_resource.always_run
    ]
  }
}

locals {
  linux_policy_id = jsondecode(restapi_object.linux_policy.api_response).ID
}
