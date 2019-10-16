#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster

locals {

  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.aws.endpoint}
    certificate-authority-data: ${aws_eks_cluster.aws.certificate_authority.0.data}
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
        - "${var.cluster_name}"
KUBECONFIG
  depends_on = ["aws_eks_cluster.aws"]
}

resource "local_file" "kubeconfig_file" {
  content = "${local.kubeconfig}"
  filename = "${var.kubeconfig_path}"
}

resource "aws_eks_cluster" "aws" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.aws-cluster.arn}"
  version  = "${var.eks_version}"

  tags = "${var.cluster_labels}"

  vpc_config {
    security_group_ids = ["${aws_security_group.aws-cluster.id}"]
    subnet_ids         = "${var.app_subnet_ids}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.aws-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.aws-cluster-AmazonEKSServicePolicy",
  ]
}
