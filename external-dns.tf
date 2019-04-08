resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    chart = "stable/external-dns"

    set {
        name = "google.project"
        value = "suse-css-platform"
    }
    set {
        name = "google.serviceAccountKey"
        value = "${var.gke_sa_key}"
    }

    depends_on = ["kubernetes_cluster_role_binding.tiller"]
}