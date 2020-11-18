locals {

  stratos_chart_values_file   = "${path.module}/stratos-config-values.yaml"
  stratos_metrics_config_file = "${path.module}/metrics-config-values.yaml"
  kubeconfig_file             = "${path.cwd}/kubeconfig"

}



resource "helm_release" "stratos" {
  name             = "susecf-console"
  repository       = "https://kubernetes-charts.suse.com"
  chart            = "console"
  namespace        = "stratos"
  wait             = "false"
  create_namespace = true

  values = [
    file(local.stratos_chart_values_file),
  ]

  set {
    name  = "env.DOMAIN"
    value = var.cap_domain
  }
  set {
    name  = "env.UAA_HOST"
    value = "uaa.${var.cap_domain}"
  }
  set {
    name  = "console.service.ingress.host"
    value = "stratos.${var.cap_domain}"
  }
  set_sensitive {
    name  = "console.localAdminPassword"
    value = var.stratos_admin_password
  }

}



resource "helm_release" "metrics" {
  name             = "susecf-metrics"
  repository       = "https://kubernetes-charts.suse.com"
  chart            = "metrics"
  namespace        = "metrics"
  wait             = "false"
  create_namespace = true

  values = [file(local.stratos_metrics_config_file)]

  set {
    name  = "kubernetes.apiEndpoint"
    value = var.cluster_url
  }
  set {
    name  = "cloudFoundry.apiEndpoint"
    value = "api.${var.cap_domain}"
  }
  set {
    name  = "metrics.service.ingress.host"
    value = "metrics.${var.cap_domain}"
  }
  set_sensitive {
    name  = "metrics.password"
    value = var.metrics_admin_password
  }
  set_sensitive {
    name  = "cloudFoundry.uaaAdminClientSecret"
    value = var.uaa_admin_client_secret
  }

  depends_on = [helm_release.stratos]
}
