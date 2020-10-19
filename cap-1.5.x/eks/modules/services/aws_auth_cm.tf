
resource "null_resource" "force-eks-dependency" {
  provisioner "local-exec" {
    command = "echo ${var.force-eks-dependency-id} > /dev/null; sleep 120"
  }
}
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<ROLES
- rolearn: ${var.worker-arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
ROLES
  }
  depends_on = [null_resource.force-eks-dependency]
}
