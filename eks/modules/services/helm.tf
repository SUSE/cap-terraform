provider "helm" {
    version = "~> 0.9.0"

  kubernetes {
    config_path = "${var.kubeconfig_path}"
  }

  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  tiller_image    = "registry.suse.com/cap/helm-tiller:2.14.2"
}
