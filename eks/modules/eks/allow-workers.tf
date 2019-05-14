resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data {
    mapRoles = <<ROLES
- rolearn: ${aws_iam_role.eks-worker.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
ROLES
}
  depends_on = ["aws_eks_cluster.eks-cluster"]
}