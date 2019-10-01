provider "helm" {
    version = "~> 0.9.0"

  kubernetes {   
    load_config_file = false
    host = "${data.aws_eks_cluster.eks.endpoint}"
    cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)}"
    token = "${data.aws_eks_cluster_auth.eks-auth.token}"
  }

  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.0"
}