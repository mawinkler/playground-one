################################################################################
# Look up the latest ECS optimized AMI
################################################################################
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
# data "aws_ssm_parameter" "ecs_optimized_ami" {
#   name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
# }

# #############################################################################
# Look up the latest Ubuntu Focal 20.04 AMI
# #############################################################################
data "aws_ami" "ecs_ami" {
    most_recent            = true
    owners                 = ["591542846629"] # Amazon

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "architecture"
        values = ["x86_64"]
    }

    filter {
        name   = "image-type"
        values = ["machine"]
    }

    filter {
        name   = "name"
        values = ["amzn2-ami-ecs-kernel-5.10-hvm-2.0.*-x86_64-ebs"]
    }
}
