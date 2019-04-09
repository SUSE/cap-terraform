resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    chart = "stable/external-dns"

    set {
        name = "google.project"
        value = "${var.project}"
    }
    set {
        name = "google.serviceAccountKey"
        value = "${var.gke_sa_key}"
    }
    set {
        name = "provider"
        value = "google"
    }

    depends_on = ["kubernetes_cluster_role_binding.tiller"]
}