provider "kubernetes" {
  load_config_file = false
  host = "https://${google_container_cluster.gke-cluster.endpoint}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.gke-cluster.master_auth.0.cluster_ca_certificate)}"
  token = "${data.google_client_config.current.access_token}"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true

  depends_on = ["google_container_node_pool.primary_preemptible_nodes"]
}

resource "kubernetes_cluster_role_binding" "tiller" {
    metadata {
        name = "tiller"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "tiller"
        namespace = "kube-system"
    }
    depends_on = ["kubernetes_service_account.tiller"]
}