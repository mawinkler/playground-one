# #############################################################################
# Locals
# #############################################################################
locals {
  kubernetes_version                 = 1.31
  autoscaler_helm_chart_name         = "cluster-autoscaler"
  autoscaler_helm_chart_release_name = "cluster-autoscaler"
  autoscaler_helm_chart_repo         = "https://kubernetes.github.io/autoscaler"
  autoscaler_helm_chart_version      = "9.46.5"
  autoscaler_create_namespace        = true
  autoscaler_namespace               = "kube-system"
  autoscaler_service_account_name    = "cluster-autoscaler"
}
