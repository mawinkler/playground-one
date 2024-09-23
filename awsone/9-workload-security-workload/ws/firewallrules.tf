# ####################################
# Deep Security Firewall Rules API
# ####################################
variable "firewall_rules" {
  type = set(string)
  default = [
    "Allow ICMP fragmentation packet (type 3, code 4)",
    "Allow solicited ICMP replies",
    "Allow solicited TCP/UDP replies",
    "ARP",
    "DHCP Server",
    "DNS Server",
    "ICMP Echo Request",
    "IDENT",
    "NetBios Name Service",
    "Remote Access SSH",
    "Web Server"
  ]
}

data "restapi_object" "firewall_rules" {
  provider     = restapi.wsrest
  path         = "/firewallrules"
  search_key   = "name"
  for_each     = var.firewall_rules
  search_value = each.value #"Allow ICMP fragmentation packet (type 3, code 4)"
  results_key  = "firewallRules"
  id_attribute = "ID"
}

locals {
  firewall_rule_allow_icmp_fragmentation_packet = jsondecode(data.restapi_object.firewall_rules["Allow ICMP fragmentation packet (type 3, code 4)"].api_response).ID
  firewall_rule_allow_solicited_icmp_replies    = jsondecode(data.restapi_object.firewall_rules["Allow solicited ICMP replies"].api_response).ID
  firewall_rule_allow_solicited_tcpudp_replies  = jsondecode(data.restapi_object.firewall_rules["Allow solicited TCP/UDP replies"].api_response).ID
  firewall_rule_arp                             = jsondecode(data.restapi_object.firewall_rules["ARP"].api_response).ID
  firewall_rule_dhcp_server                     = jsondecode(data.restapi_object.firewall_rules["DHCP Server"].api_response).ID
  firewall_rule_dns_server                      = jsondecode(data.restapi_object.firewall_rules["DNS Server"].api_response).ID
  firewall_rule_icmp_echo_request               = jsondecode(data.restapi_object.firewall_rules["ICMP Echo Request"].api_response).ID
  firewall_rule_ident                           = jsondecode(data.restapi_object.firewall_rules["IDENT"].api_response).ID
  firewall_rule_netbios_name_service            = jsondecode(data.restapi_object.firewall_rules["NetBios Name Service"].api_response).ID
  firewall_rule_web_remote_access_ssh           = jsondecode(data.restapi_object.firewall_rules["Remote Access SSH"].api_response).ID
  firewall_rule_web_server                      = jsondecode(data.restapi_object.firewall_rules["Web Server"].api_response).ID
}
