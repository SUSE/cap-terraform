#
# Outputs
#

locals {
  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${var.aws_eks_cluster_endpoint}
    certificate-authority-data: ${var.aws_eks_cluster_certificate_authority_data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - ${var.aws_eks_cluster_name}
KUBECONFIG
}

resource "local_file" "kubeconfig_file" {
  content  = local.kubeconfig
  filename = "${path.cwd}/kubeconfig"

  depends_on = [kubernetes_config_map.aws_auth]
}
