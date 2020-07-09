locals {
  chart_values_file           = "${path.cwd}/scf-config-values.yaml"
  stratos_metrics_config_file = "${path.cwd}/stratos-metrics-values.yaml"
}

resource "kubernetes_namespace" "uaa" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "uaa"
  }
}

resource "kubernetes_namespace" "scf" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "scf"
  }
}

resource "kubernetes_namespace" "stratos" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "stratos"
  }
}

resource "kubernetes_namespace" "metrics" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "metrics"
  }
}

# Install UAA using Helm Chart
resource "helm_release" "uaa" {
  name       = "scf-uaa"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "uaa"
  namespace  = "uaa"
  wait       = "false"

  values = [
    file(local.chart_values_file),
  ]

  depends_on = [
    helm_release.external-dns,
    helm_release.nginx_ingress,
    null_resource.cluster_issuer_setup,
    kubernetes_namespace.uaa
  ]
}

resource "helm_release" "scf" {
  name       = "scf-cf"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "cf"
  namespace  = "scf"
  wait       = "false"

  values = [
    file(local.chart_values_file),
  ]

  depends_on = [
    helm_release.uaa,
    kubernetes_namespace.scf
  ]
}

resource "helm_release" "stratos" {
  name       = "susecf-console"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "console"
  namespace  = "stratos"
  wait       = "false"

  values = [
    file(local.chart_values_file),
  ]

  set {
    name  = "services.loadbalanced"
    value = "true"
  }
  set {
    name  = "console.techPreview"
    value = "true"
  }

  depends_on = [
    helm_release.scf,
    kubernetes_namespace.stratos
  ]
}

resource "null_resource" "metrics" {
  provisioner "local-exec" {
    command = "/bin/sh deploy_metrics.sh "

    environment = {
      "METRICS_FILE" = local.stratos_metrics_config_file
      "SCF_FILE"     = local.chart_values_file
    }
  }
  depends_on = [
    helm_release.stratos,
    kubernetes_namespace.metrics
  ]
}

resource "null_resource" "update_stratos_dns" {
  provisioner "local-exec" {
    command = "/bin/sh ext-dns-stratos-svc-annotate.sh"

    environment = {
      "DOMAIN" = var.cap_domain
    }
  }
  depends_on = [helm_release.stratos]
}

resource "null_resource" "update_metrics_dns" {
  provisioner "local-exec" {
    command = "/bin/sh ext-dns-metrics-svc-annotate.sh"

    environment = {
      "DOMAIN" = var.cap_domain
    }
  }
  depends_on = [null_resource.metrics]
}

