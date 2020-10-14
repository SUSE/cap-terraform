resource "kubernetes_secret" "google_dns_sa_creds" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "dns-sa-creds"
  }

  data = {
    "credentials.json" = var.dns_credentials_json
  }
}

resource "helm_release" "external-dns" {
  name = "cap-external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "external-dns"
  wait = "false"

  set {
    name  = "google.project"
    value = var.project
  }
  set {
    name  = "google.serviceAccountSecret"
    value = kubernetes_secret.google_dns_sa_creds.metadata[0].name
  }
  set {
    name  = "provider"
    value = "google"
  }

  set {
    name  = "logLevel"
    value = "debug"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  depends_on = [google_container_node_pool.np]
}

