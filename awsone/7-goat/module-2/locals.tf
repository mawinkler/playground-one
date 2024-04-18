locals {
    userdata_linux = templatefile("${path.module}/resources/ecs/user_data.tpl", {
        cluster_name = aws_ecs_cluster.cluster.name
    })
}