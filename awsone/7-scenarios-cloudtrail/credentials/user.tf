# #############################################################################
# Attacker User
# #############################################################################
resource "aws_iam_user" "attacker" {
  name = "${var.environment}-attacker-${random_string.suffix.result}"

  tags = {
    Name          = "${var.environment}-attacker-${random_string.suffix.result}"
    Environment   = "${var.environment}"
    Product       = "playground-one"
    Configuration = "scenarios-cloudtrail"
  }
}

resource "aws_iam_access_key" "attacker_access_key" {
  user = aws_iam_user.attacker.name
}

# User Policy Attachments
resource "aws_iam_user_policy_attachment" "attacker_policy" {
  user       = aws_iam_user.attacker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
