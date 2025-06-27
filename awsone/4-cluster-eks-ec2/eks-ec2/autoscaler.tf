# #############################################################################
# EC2 Autoscaler
# #############################################################################
resource "kubernetes_namespace" "cluster_autoscaler" {
  # depends_on = [var.autoscaler_dependency]
  count = (var.autoscaler_enabled && local.autoscaler_create_namespace && local.autoscaler_namespace != "kube-system") ? 1 : 0

  metadata {
    name = local.autoscaler_namespace
  }
}

# https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler
resource "helm_release" "cluster_autoscaler" {
  # depends_on = [var.autoscaler_dependency, kubernetes_namespace.cluster_autoscaler]
  # depends_on = [kubernetes_namespace.cluster_autoscaler, module.fargate_profile]
  depends_on = [kubernetes_namespace.cluster_autoscaler]
  count      = var.autoscaler_enabled ? 1 : 0
  name       = local.autoscaler_helm_chart_name
  chart      = local.autoscaler_helm_chart_release_name
  repository = local.autoscaler_helm_chart_repo
  version    = local.autoscaler_helm_chart_version
  namespace  = local.autoscaler_namespace

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = local.autoscaler_service_account_name
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.kubernetes_cluster_autoscaler[0].arn
  }

  values = [
    yamlencode(var.autoscaler_additional_settings)
  ]
}
