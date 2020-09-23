provider "kubernetes" {
  version = "~> 1.10.0"
  load_config_file = false
  host = "https://${google_container_cluster.gke-cluster.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.gke-cluster.master_auth.0.cluster_ca_certificate)
  token = data.google_client_config.current.access_token
}

resource "kubernetes_storage_class" "gkesc" {
  metadata {
    name = "persistent"
    annotations = {"storageclass.kubernetes.io/is-default-class" = "true"}
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  parameters = {
    type = "pd-ssd"
  }
}
