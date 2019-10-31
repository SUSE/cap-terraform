#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster

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
    "aws_iam_role_policy_attachment.aws-node-AmazonEKS_CNI_Policy",
    "aws_security_group_rule.aws-cluster-ingress-node-https",
    "aws_security_group_rule.aws-cluster-ingress-workstation-https",
//    "aws_iam_role_policy_attachment.aws-node-AmazonRoute53ReadOnlyAccess",
    "aws_iam_role_policy_attachment.aws-node-AmazonRoute53FullAccess",
    "aws_iam_role_policy_attachment.aws-node-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.aws-node-AmazonEC2ContainerRegistryReadOnly"
  ]
}
