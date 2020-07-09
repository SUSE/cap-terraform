provider "kubernetes" {
  version          = "~> 1.5"
  load_config_file = false
  host             = "https://${google_container_cluster.gke-cluster.endpoint}"
  cluster_ca_certificate = base64decode(
    google_container_cluster.gke-cluster.master_auth[0].cluster_ca_certificate,
  )
  token = data.google_client_config.current.access_token
}

resource "kubernetes_storage_class" "gkesc" {
  depends_on = [null_resource.post_processor]

  metadata {
    name = "persistent"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  parameters = {
    type = "pd-ssd"
  }
}

