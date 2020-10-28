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
    value = var.dns_credentials_json_secret_key_name
  }
  set {
    name  = "provider"
    value = var.service_provider
  }

  set {
    name  = "logLevel"
    value = "debug"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

}
