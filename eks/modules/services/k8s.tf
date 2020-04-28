data "aws_eks_cluster" "eks" {
  name = var.aws-eks-cluster-name
}

data "aws_eks_cluster_auth" "eks-auth" {
  name = var.aws-eks-cluster-name
}

provider "kubernetes" {
  version                = "1.10.0"
  load_config_file       = false
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks-auth.token
}

//To do
// Add a storage class resource with name "persistent"
resource "kubernetes_storage_class" "persistent" {
  metadata {
    name = "persistent"
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  parameters = {
    type = "gp2"
  }
  depends_on = [kubernetes_config_map.aws_auth]
}
resource "kubernetes_storage_class" "scopedpersistent" {
  metadata {
    name = "scopedpersistent"
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  parameters = {
    type = "gp2"
  }
  depends_on = [kubernetes_config_map.aws_auth]
}
