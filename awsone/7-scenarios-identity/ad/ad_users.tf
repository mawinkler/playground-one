# #############################################################################
# AD Users
# #############################################################################
resource "ad_user" "u1" {
  display_name     = "${var.user_basename} 1"
  principal_name   = "${replace(var.user_basename, " ", "")}1"
  sam_account_name = "${replace(var.user_basename, " ", "")}1"
  initial_password = var.initial_password
  container        = var.users_dn
}

resource "ad_user" "u2" {
  display_name     = "${var.user_basename} 2"
  principal_name   = "${replace(var.user_basename, " ", "")}2"
  sam_account_name = "${replace(var.user_basename, " ", "")}2"
  initial_password = var.initial_password
  container        = var.users_dn
}

resource "ad_user" "u3" {
  display_name     = "${var.user_basename} 3"
  principal_name   = "${replace(var.user_basename, " ", "")}3"
  sam_account_name = "${replace(var.user_basename, " ", "")}3"
  initial_password = var.initial_password
  container        = var.users_dn
}
