# resource "aws_ec2_tag" "sg" {
#   depends_on = [ aws_security_group.sg["public"] ]
#   resource_id = aws_security_group.sg["public"].id
#   key         = "ExceptionId"
#   value       = "1234567890"
# }
