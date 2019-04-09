resource "helm_release" "uaa-opensuse" {
  name = "uaa-opensuse"
  namespace = "uaa"
  chart = "./scf-opensuse-2.15.2/helm/uaa-opensuse"
  depends_on = ["helm_release.nginx_ingress"]

  values = [
    "${file("scf-config-values-ingress.yaml")}"
  ]
}

