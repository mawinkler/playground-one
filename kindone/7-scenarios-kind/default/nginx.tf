resource "kubernetes_deployment" "nginx_deployment" {
  metadata {
    name = "nginx"
    labels = {
      workertype = "ec2"
    }
    namespace = var.namespace
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        workertype = "ec2"
      }
    }
    template {
      metadata {
        labels = {
          workertype = "ec2"
        }
      }
      spec {
        container {
          image = "nginx:1.18.0-alpine"
          # image = "nginx"
          name = "nginx"
          port {
            container_port = 80
          }
          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "nginx-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "nginx"
    }
    type = "NodePort"
    port {
      port        = 80
      target_port = 80
    }
  }
}
