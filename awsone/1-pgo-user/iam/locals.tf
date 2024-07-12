# #############################################################################
# Locals
# #############################################################################
locals {
  policy_ec2 = templatefile("${path.module}/policy_ec2.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_ecs = templatefile("${path.module}/policy_ecs.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_eks = templatefile("${path.module}/policy_eks.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_iam = templatefile("${path.module}/policy_iam.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_kms = templatefile("${path.module}/policy_kms.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_lambda = templatefile("${path.module}/policy_lambda.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_rds = templatefile("${path.module}/policy_rds.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_s3 = templatefile("${path.module}/policy_s3.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })

  policy_svc = templatefile("${path.module}/policy_svc.tftpl", {
    Region  = var.aws_region
    Account = var.aws_account_id
  })
}
