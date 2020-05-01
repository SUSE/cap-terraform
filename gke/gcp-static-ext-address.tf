resource "google_compute_address" "ingress-ext-address" {
  name = "ingress-address-${var.cluster_name}"
}

