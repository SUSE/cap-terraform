# Install UAA using Helm Chart
resource "helm_release" "uaa" {
  name       = "scf-uaa"
  repository = "${data.helm_repository.suse.metadata.0.name}"
  chart      = "uaa"
  namespace  = "uaa"
  wait       = "true"
  timeout    = "2000"

  values = [
    "${file("${var.chart_values_file}")}"
  ]

  depends_on = ["helm_release.external-dns", "helm_release.nginx_ingress", "null_resource.cluster_issuer_setup"]
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

    depends_on = ["helm_release.uaa"]
  }
