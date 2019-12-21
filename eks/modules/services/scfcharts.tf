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

resource "helm_release" "stratos" {
    name       = "susecf-console"
    #repository = "${data.helm_repository.suse.metadata.0.name}"
    chart      = "./console"
    namespace  = "stratos"
    wait       = "false"

    values = [
    "${file("${var.chart_values_file}")}"
  ]

   set {
    name  = "services.loadbalanced"
    value = "true"
  }
   set {
    name  = "console.techPreview"
    value = "true"
  }

   set {
    name  = "kube.storage_class.persistent"
    value = "scopedpersistent"
  }
    depends_on = ["helm_release.scf"]
  }

resource "null_resource" "metrics" {

  provisioner "local-exec" {
    command = "/bin/sh modules/services/deploy_metrics.sh "

    environment = {
        "METRICS_FILE" = "${var.stratos_metrics_config_file}"
        "SCF_FILE" = "${var.chart_values_file}"
        "KUBECONFIG" = "${var.kubeconfig_file_path}"

    }

  }
  depends_on = ["helm_release.stratos"]
}

resource "null_resource" "update_stratos_dns" {

  provisioner "local-exec" {
    command = "/bin/sh modules/services/ext-dns-stratos-svc-annotate.sh"

    environment = {
        "DOMAIN" = "${var.cap_domain}"
	"KUBECONFIG" = "${var.kubeconfig_file_path}"
    }

  }
  depends_on = ["helm_release.stratos"]
}

resource "null_resource" "update_metrics_dns" {

  provisioner "local-exec" {
    command = "/bin/sh modules/services/ext-dns-metrics-svc-annotate.sh"

    environment = {
        "DOMAIN" = "${var.cap_domain}"
        "KUBECONFIG" = "${var.kubeconfig_file_path}"

    }

  }
  depends_on = ["null_resource.metrics"]
}


