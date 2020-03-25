data "aws_eks_cluster" "eks" {
  name = var.eks-cluster-name
}

data "aws_eks_cluster_auth" "eks-auth" {
  name = var.eks-cluster-name
}

provider "kubernetes" {
  version = "~> 1.10.0"
  load_config_file = false
  host = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)}"
  token = data.aws_eks_cluster_auth.eks-auth.token
}