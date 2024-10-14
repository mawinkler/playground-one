# #############################################################################
# Group Policy Object
# #############################################################################
# resource "ad_gpo" "gpo" {
#   name   = var.gpo_name
#   domain = var.windows_ad_domain_name
# }

# resource "ad_gpo_security" "gpo_sec" {
#   gpo_container = ad_gpo.gpo.id

#   password_policies {
#     minimum_password_length = 3
#     password_complexity     = 0
#   }
# }
