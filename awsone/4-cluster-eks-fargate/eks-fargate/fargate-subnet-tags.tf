# #############################################################################
# Tag Private Subnets for Fargate
# #############################################################################
resource "aws_ec2_tag" "fargate_tags" {
  for_each    = toset(var.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.environment}-eks-fg-${random_string.suffix.result}"
  value       = "shared"
}
