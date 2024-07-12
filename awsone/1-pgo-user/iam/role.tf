# #############################################################################
# PGO Role
# #############################################################################
# resource "aws_iam_role" "pgo_role" {
#   name = "${var.environment}-pgo-${random_string.suffix.result}"
#   # assume_role_policy = data.aws_iam_policy_document.assume_role.json
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = "sts:AssumeRole"
#         Sid    = ""
#         Principal = {
#           "AWS" : "634503960501"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "pgo_attach_ec2" {
#   role       = aws_iam_role.pgo_role.name
#   policy_arn = aws_iam_policy.pgo_policy_ec2.arn
# }

# resource "aws_iam_role_policy_attachment" "pgo_attach_iam" {
#   role       = aws_iam_role.pgo_role.name
#   policy_arn = aws_iam_policy.pgo_policy_iam.arn
# }

# resource "aws_iam_role_policy_attachment" "pgo_attach_svc" {
#   role       = aws_iam_role.pgo_role.name
#   policy_arn = aws_iam_policy.pgo_policy_svc.arn
# }
