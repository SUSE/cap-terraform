
resource "kubernetes_secret" "google_dns_sa_creds" {
  metadata {
    name = "dns-sa-creds"
  }

  data {
    "credentials.json" = "${file("${var.gcp_dns_sa_key}")}"
  }
}
resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    chart = "stable/external-dns"

    set {
        name = "google.project"
        value = "${var.project}"
    }
    set {
        name = "google.serviceAccountSecret"
        value = "${kubernetes_secret.google_dns_sa_creds.metadata.0.name}"
    }
    set {
        name = "provider"
        value = "google"
    }

    set {
        name = "logLevel"
        value = "debug"
    }

    set {
        name = "rbac.create"
        value = "true"
    }

    depends_on = ["kubernetes_cluster_role_binding.tiller"]
}