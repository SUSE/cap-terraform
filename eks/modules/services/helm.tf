provider "helm" {
  version = "1.2.4"
  
  kubernetes {
    load_config_file = false
    host = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command = "aws-iam-authenticator"
      args = [
	      "token",
        "-i",
        var.aws-eks-cluster-name
      ]
      env = {
        "AWS_ACCESS_KEY_ID" = var.access_key_id
        "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
      }
    }  
  }
}
