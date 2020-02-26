provider "helm" {
    version = "~> 1.0.0"

  kubernetes {   
    load_config_file = false
    host = "https://${google_container_cluster.gke-cluster.endpoint}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.gke-cluster.master_auth.0.cluster_ca_certificate)}"
    token = "${data.google_client_config.current.access_token}"
  }

#  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
#  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"
#  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.12.0"
}


