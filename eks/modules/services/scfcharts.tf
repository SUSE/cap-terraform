# Install UAA using Helm Chart
resource "helm_release" "uaa" {
  name       = "scf-uaa"
  repository = "${data.helm_repository.suse.metadata.0.name}"
  chart      = "uaa"
  namespace  = "uaa"
  wait       = "false"

  values = [
    "${file("${var.chart_values_file}")}"
  ]

  depends_on = ["helm_release.external-dns", "helm_release.nginx_ingress", "helm_release.cert-manager"]
}

resource "helm_release" "scf" {
    name       = "scf-cf"
    repository = "${data.helm_repository.suse.metadata.0.name}"
    chart      = "cf"
    namespace  = "scf"
    wait       = "false"

    values = [
    "${file("${var.chart_values_file}")}"
  ]

    depends_on = ["helm_release.external-dns", "helm_release.nginx_ingress", "helm_release.cert-manager"]
  }
