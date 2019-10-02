resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data =  {
    mapRoles = <<ROLES
- rolearn: ${var.worker-arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
ROLES
}
  depends_on = ["kubernetes_cluster_role_binding.tiller"]
}