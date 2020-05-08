#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster


resource "aws_eks_cluster" "aws" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.eks_version

  tags = var.cluster_labels

  vpc_config {
    security_group_ids = [aws_security_group.aws-cluster.id]
    subnet_ids         = var.app_subnet_ids
  }


  depends_on = []
}
