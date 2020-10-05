locals {

  //chart_values_file           = (var.cap_version == 2) ? "${path.module}/kubecf-config-values.yaml" : "${path.module}/scf-config-values.yaml"
  chart_values_file           = "${path.module}/kubecf-config-values.yaml"
  stratos_chart_values_file   = "${path.module}/stratos-config-values.yaml"
  stratos_metrics_config_file = "${path.module}/metrics-config-values.yaml"
  kubeconfig_file             = "${path.cwd}/kubeconfig"

}
/* 
# Install UAA using Helm Chart
resource "helm_release" "uaa" {
  name       = "scf-uaa"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "uaa"
  namespace  = "uaa"
  wait       = "false"
  create_namespace = true

  count = (var.cap_version == 2) ? 0 : 1

  values = [
    file(local.chart_values_file)
  ]
  
} */

/* resource "helm_release" "scf" {
  name       = "scf-cf"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "cf"
  namespace  = "scf"
  wait       = "false"
  create_namespace = true

  count = (var.cap_version == 2) ? 0 : 1

  values = [
    file(local.chart_values_file)
  ]

  set {
      name = "env.DOMAIN"
      value = var.cap_domain
  }

  set {
      name = "env.UAA_HOST"
      value = "uaa.${var.cap_domain}"
  }

  set {
      name = "enable.uaa"
      value = "true"
  }

 // depends_on = [helm_release.uaa] 
} */

resource "helm_release" "cf-operator" {
  name             = "cf-operator"
  repository       = "https://kubernetes-charts.suse.com"
  chart            = "cf-operator"
  namespace        = "cfo"
  wait             = "true"
  create_namespace = true

  set {
    name  = "global.operator.watchNamespace"
    value = "kubecf"
  }

  //  count = (var.cap_version == 2) ? 1 : 0

}

//Setting values from a config file as-well-as command line goes against helm best practices 
// but is perhaps unavoidable here to keep things DRY for various domain related settings

resource "helm_release" "kubecf" {
  name             = "kubecf"
  repository       = "https://kubernetes-charts.suse.com"
  chart            = "kubecf"
  namespace        = "kubecf"
  wait             = "false"
  create_namespace = true

  values = [
    file(local.chart_values_file),
  ]

  set {
    name  = "system_domain"
    value = var.cap_domain
  }
  set_sensitive {
    name  = "credentials.cf_admin_password"
    value = var.cf_admin_password
  }
  set_sensitive {
    name  = "credentials.uaa_admin_client_secret"
    value = var.uaa_admin_client_secret
  }

  //  count = (var.cap_version == 2) ? 1 : 0

  depends_on = [helm_release.cf-operator]

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

  depends_on = [helm_release.kubecf]
}


resource "null_resource" "wait_for_uaa" {
  provisioner "local-exec" {
    command     = "./common/cap-charts/wait_for_uaa.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]

    environment = {
      METRICS_API_ENDPOINT = var.cap_domain
    }
  }

  depends_on = [helm_release.stratos]
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

  depends_on = [null_resource.wait_for_uaa]
}
