#
# Outputs
#

locals {

  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${module.eks.aws-eks-cluster-endpoint}
    certificate-authority-data: ${module.eks.aws-eks-cluster-certificate-authority-data}
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
        - "${module.eks.eks-cluster-name}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "aws-route53-hostedzone-policy" {
  value = "${module.services.aws_route53_hosted_zone_policy}"
}
