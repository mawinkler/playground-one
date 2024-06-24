# #############################################################################
# AD Group Memberships
# #############################################################################
resource "ad_group_membership" "gm1" {
  group_id      = ad_group.g1.id
  group_members = [ad_group.g2.id, ad_user.u1.id]
}

resource "ad_group_membership" "gm2" {
  group_id      = ad_group.g2.id
  group_members = [ad_user.u2.id]
}

resource "ad_group_membership" "gm3" {
  group_id      = data.ad_group.domain_admins.sam_account_name
  group_members = [ad_user.u3.id]
}
