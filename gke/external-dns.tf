
resource "kubernetes_secret" "google_dns_sa_creds" {
  metadata {
    name = "dns-sa-creds"
  }

  data = {
    "credentials.json" = file(var.gcp_dns_sa_key)
  }
}

data "helm_repository" "external-dns-repo" {
  name = "external-dns-chart-repo"
  url  = "https://charts.bitnami.com/bitnami"
}


resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    repository = data.helm_repository.external-dns-repo.metadata[0].name
    chart = "bitnami/external-dns"
    wait = "false"

    set {
        name = "google.project"
        value = var.project
    }
    set {
        name = "google.serviceAccountSecret"
        value = kubernetes_secret.google_dns_sa_creds.metadata.0.name
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

    depends_on = [null_resource.post_processor]

}
