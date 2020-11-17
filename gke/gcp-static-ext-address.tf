resource "google_compute_address" "ingress-ext-address" {
  # Use the google-beta provider to get support for labels
  provider = google-beta
  name = "ingress-address-${var.cluster_name}"
  labels = var.cluster_labels
}

