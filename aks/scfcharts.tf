# Add SUSE Helm charts repo
data "helm_repository" "suse" {
  name = "suse"
  url  = "https://kubernetes-charts.suse.com"
}

locals {
    chart_values_file = "${path.cwd}/scf-config-values.yaml"
    stratos_metrics_config_file = "${path.cwd}/stratos-metrics-values.yaml"
}

# Install UAA using Helm Chart
resource "helm_release" "uaa" {
  name       = "scf-uaa"
  repository = "${data.helm_repository.suse.metadata.0.name}"
  chart      = "uaa"
  namespace  = "uaa"
  wait       = "false"

  values = [
    "${file("${local.chart_values_file}")}"
  ]
  # scf-config-values
  set {
    name = "env.DOMAIN"
    value = "${var.cap_domain}"
  }
  set {
    name = "env.UAA_HOST"
    value = "uaa.${var.cap_domain}"
  }
  set_sensitive {
    name = "secrets.UAA_ADMIN_CLIENT_SECRET"
    value = "${var.uaa_admin_client_secret}"
  }

  depends_on = ["helm_release.external-dns", "helm_release.nginx_ingress", "null_resource.cluster_issuer_setup"]
}

resource "helm_release" "scf" {
    name       = "scf-cf"
    repository = "${data.helm_repository.suse.metadata.0.name}"
    chart      = "cf"
    namespace  = "scf"
    wait       = "false"

    values = [
        "${file("${local.chart_values_file}")}"
    ]
    # scf-config-values
    set {
      name = "env.DOMAIN"
      value = "${var.cap_domain}"
    }
    set {
      name = "env.UAA_HOST"
      value = "uaa.${var.cap_domain}"
    }
    set_sensitive {
      name = "secrets.CLUSTER_ADMIN_PASSWORD"
      value = "${var.cluster_admin_password}"
    }
    set_sensitive {
      name = "secrets.UAA_ADMIN_CLIENT_SECRET"
      value = "${var.uaa_admin_client_secret}"
    }

    depends_on = ["helm_release.uaa"]
  }


resource "helm_release" "stratos" {
    name       = "susecf-console"
    repository = "${data.helm_repository.suse.metadata.0.name}"
    chart      = "console"
    namespace  = "stratos"
    wait       = "false"

    values = [
        "${file("${local.chart_values_file}")}"
    ]
    # scf-config-values
    set {
      name = "env.DOMAIN"
      value = "${var.cap_domain}"
    }
    set {
      name = "env.UAA_HOST"
      value = "uaa.${var.cap_domain}"
    }
   set {
    name  = "services.loadbalanced"
    value = "true"
  }
   set {
    name  = "console.techPreview"
    value = "true"
  }

    depends_on = ["helm_release.scf"]
  }

resource "helm_release" "metrics" {
    name       = "susecf-metrics"
    repository = "${data.helm_repository.suse.metadata.0.name}"
    chart      = "metrics"
    namespace  = "metrics"
    wait       = "false"

    values = [
        "${file("${local.stratos_metrics_config_file}")}"
    ]
    set {
      name = "metrics.username"
      value = "${var.metrics_username}"
    }
    set_sensitive {
      name = "metrics.password"
      value = "${var.metrics_password}"
    }
    set {
      name = "kubernetes.apiEndpoint"
      value = "${var.cap_domain}"
    }

  depends_on = ["helm_release.stratos"]
}

resource "null_resource" "update_stratos_dns" {

  provisioner "local-exec" {
    command = "/bin/sh ext-dns-stratos-svc-annotate.sh"

    environment = {
        RESOURCE_GROUP = "${var.resource_group}"
        CLUSTER_NAME = "${azurerm_kubernetes_cluster.k8s.name}"
        AZ_CERT_MGR_SP_PWD = "${var.client_secret}"
	DOMAIN="${var.cap_domain}"

    }

  }
  depends_on = ["helm_release.stratos"]
}



resource "null_resource" "update_metrics_dns" {

  provisioner "local-exec" {
    command = "/bin/sh ext-dns-metrics-svc-annotate.sh"

    environment = {
        RESOURCE_GROUP = "${var.resource_group}"
        CLUSTER_NAME = "${azurerm_kubernetes_cluster.k8s.name}"
        AZ_CERT_MGR_SP_PWD = "${var.client_secret}"
        DOMAIN="${var.cap_domain}"

    }

  }
  depends_on = ["helm_release.metrics"]
}
