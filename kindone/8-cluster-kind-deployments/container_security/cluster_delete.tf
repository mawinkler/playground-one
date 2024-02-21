# ####################################
# Delete cluster from Vision One on destroy
# ####################################
# resource "null_resource" "cluster_delete" {
#   triggers = {
#     api_key    = var.api_key
#     cluster_id = local.cluster_id
#   }
#   provisioner "local-exec" {
#     when    = destroy
#     command = <<SCRIPT
#       curl -fsSL -X DELETE \
#         -H "Content-Type: application/json" \
#         -H "api-version: v1" -H "Authorization: Bearer ${self.triggers.api_key}" \
#         "https://api.xdr.trendmicro.com/beta/containerSecurity/kubernetesClusters/${self.triggers.cluster_id}"
#     SCRIPT
#   }
# }
