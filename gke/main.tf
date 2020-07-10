resource "random_string" "cluster_name" {
  length  = 18
  special = false
  upper   = false
  number  = false
}

locals {
  cluster_node_image = "ubuntu"
}

resource "google_container_cluster" "gke-cluster" {
  name     = "cap-${random_string.cluster_name.result}"
  location = var.location
  min_master_version = "1.15"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true

  initial_node_count = 1

  resource_labels = var.cluster_labels

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }

    horizontal_pod_autoscaling {
      disabled = true
    }
  }
}

resource "google_container_node_pool" "np" {
  name       = "${google_container_cluster.gke-cluster.name}-node-pool"
  location   = var.location
  cluster    = google_container_cluster.gke-cluster.name
  node_count = var.instance_count

  node_config {
    preemptible  = false
    machine_type = var.instance_type
    disk_size_gb = var.disk_size_gb
    image_type   = local.cluster_node_image

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_repair  = false
    auto_upgrade = false
  }
}

resource "local_file" "kubeconfig" {
  # it's only good for one hour, though
  content  = templatefile("kubeconfig.tmpl", {
    cluster_name = google_container_cluster.gke-cluster.name
    endpoint     = google_container_cluster.gke-cluster.endpoint
    cluster_ca   = google_container_cluster.gke-cluster.master_auth[0].cluster_ca_certificate
    token        = data.google_client_config.current.access_token
  })
  filename = "${path.module}/kubeconfig"

  depends_on = [google_container_node_pool.np]
}

data "google_client_config" "current" {
}

