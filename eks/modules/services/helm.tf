provider "helm" {
    version = "~> 0.9.0"

  kubernetes {
    config_path = "${var.kubeconfig_file_path}"
  }

  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.16.1"
}
