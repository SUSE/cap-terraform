
resource "null_resource" "force-eks-dependency" {
    provisioner "local-exec" {
    command = "echo ${var.force-eks-dependency-id} > /dev/null"
  }
}
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"  
    namespace = "kube-system"
  }

  data = var.kube_authorized_role_arn == "" ?  {
    mapRoles = <<ROLES
- rolearn: ${var.worker-arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
ROLES
} : {
    mapRoles = <<ROLES
- rolearn: ${var.worker-arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${var.kube_authorized_role_arn}
  username: eksadmin
  groups:
    - system:masters
ROLES
}

depends_on = [null_resource.force-eks-dependency]
}