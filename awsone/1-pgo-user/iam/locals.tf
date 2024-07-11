# #############################################################################
# Locals
# #############################################################################
locals {
  policy_ec2 = templatefile("${path.module}/policy_ec2.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_iam = templatefile("${path.module}/policy_iam.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_svc = templatefile("${path.module}/policy_svc.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })
}
