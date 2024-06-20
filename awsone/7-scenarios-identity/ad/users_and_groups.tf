variable "principal_name" { default = "testuser" }
variable "samaccountname" { default = "testuser" }
variable "container" { default = "CN=Users,DC=pgo-id,DC=local" }

variable "name" { default = "test group" }
variable "sam_account_name" { default = "TESTGROUP" }
variable "scope" { default = "global" }
variable "category" { default = "security" }


# resource "random_password" "user_password" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# resource "ad_user" "u1" {
#   display_name     = "test user 1"
#   principal_name   = "testUser1"
#   sam_account_name = "testUser1"
#   initial_password = "SuperSecure1234!!"
#   custom_attributes = jsonencode({
#     "carLicense" : ["This is", "a multi-value", "attribute"],
#     "comment" : "and this is a single value attribute"
#   })
# }

resource "ad_user" "u1" {
  display_name     = "test user 1"
  principal_name   = "testUser1"
  sam_account_name = "testUser1"
  initial_password = "SuperSecure1234!!"
  container        = var.container
}

resource "ad_user" "u2" {
  display_name     = "test user 2"
  principal_name   = "testUser2"
  sam_account_name = "testUser2"
  initial_password = "SuperSecure1234!!"
  container        = var.container
}

resource "ad_group" "g1" {
  name             = "${var.name}-1"
  sam_account_name = "${var.sam_account_name}-1"
  scope            = var.scope
  category         = var.category
  container        = var.container
}

resource "ad_group" "g2" {
  name             = "${var.name}-2"
  sam_account_name = "${var.sam_account_name}-2"
  container        = var.container
}

resource "ad_group_membership" "gm" {
  group_id      = ad_group.g1.id
  group_members = [ad_group.g2.id, ad_user.u2.id]
}
