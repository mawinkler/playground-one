# #############################################################################
# AD Groups
# #############################################################################
resource "ad_group" "g1" {
  name             = "${var.group_basename} 1"
  sam_account_name = "${var.sam_account_name}-1"
  scope            = var.scope
  category         = var.category
  container        = var.users_dn
}

resource "ad_group" "g2" {
  name             = "${var.group_basename} 2"
  sam_account_name = "${var.sam_account_name}-2"
  container        = var.users_dn
}
