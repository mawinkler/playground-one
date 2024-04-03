# #############################################################################
# Locals
# #############################################################################
locals {
  backend_address_pool_name      = "${var.environment}-beap-${random_pet.pet.id}"
  frontend_port_name             = "${var.environment}-feport-${random_pet.pet.id}"
  frontend_ip_configuration_name = "${var.environment}-feip-${random_pet.pet.id}"
  http_setting_name              = "${var.environment}-be-htst-${random_pet.pet.id}"
  listener_name                  = "${var.environment}-httplstn-${random_pet.pet.id}"
  request_routing_rule_name      = "${var.environment}-rqrt-${random_pet.pet.id}"
}
