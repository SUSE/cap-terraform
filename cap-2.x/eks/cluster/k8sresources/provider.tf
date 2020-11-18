provider "kubernetes" {
  version                = "1.13.3"
  load_config_file       = false
  host                   = var.aws_eks_cluster_endpoint
  cluster_ca_certificate = base64decode(var.aws_eks_cluster_certificate_authority_data)
  token                  = var.aws_eks_auth_token
}
