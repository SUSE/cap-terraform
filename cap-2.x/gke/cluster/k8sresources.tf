provider "kubernetes" {
  version          = "1.13.2"
  load_config_file = false
  host             = "https://${google_container_cluster.gke-cluster.endpoint}"
  cluster_ca_certificate = base64decode(
    google_container_cluster.gke-cluster.master_auth[0].cluster_ca_certificate,
  )
  token = data.google_client_config.current.access_token
}

resource "kubernetes_storage_class" "gkesc" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "persistent"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  parameters = {
    type = "pd-ssd"
  }
}

resource "kubernetes_secret" "google_dns_sa_creds" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "dns-sa-creds"
  }

  data = {
    "credentials.json" = var.dns_credentials_json
  }
}

output "dns_credentials_json_secret_key_name" {
    value = kubernetes_secret.google_dns_sa_creds.metadata[0].name
}
