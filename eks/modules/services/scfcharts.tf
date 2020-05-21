locals {
  chart_values_file           = "${path.cwd}/scf-config-values.yaml"
  stratos_metrics_config_file = "${path.cwd}/stratos-metrics-values.yaml"
}

resource "kubernetes_namespace" "uaa" {
  metadata {
    name = "uaa"
  }
}

resource "kubernetes_namespace" "scf" {
  metadata {
    name = "scf"
  }
}

resource "kubernetes_namespace" "stratos" {
  metadata {
    name = "stratos"
  }
}

resource "kubernetes_namespace" "metrics" {
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

  # scf-config-values
  set {
    name  = "env.DOMAIN"
    value = var.cap_domain
  }
  set {
    name  = "env.UAA_HOST"
    value = "uaa.${var.cap_domain}"
  }
  set_sensitive {
    name = "secrets.CLUSTER_ADMIN_PASSWORD"
    value = var.stratos_admin_password
  }
  set_sensitive {
    name = "secrets.UAA_ADMIN_CLIENT_SECRET"
    value = var.uaa_admin_client_secret
  }

  depends_on = [
    helm_release.external-dns,
    helm_release.nginx_ingress,
    helm_release.cert-manager,
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

  # scf-config-values
  set {
    name  = "env.DOMAIN"
    value = var.cap_domain
  }
  set {
    name  = "env.UAA_HOST"
    value = "uaa.${var.cap_domain}"
  }
  set_sensitive {
    name = "secrets.CLUSTER_ADMIN_PASSWORD"
    value = var.stratos_admin_password
  }
  set_sensitive {
    name = "secrets.UAA_ADMIN_CLIENT_SECRET"
    value = var.uaa_admin_client_secret
  }
  depends_on = [
    helm_release.external-dns,
    helm_release.nginx_ingress,
    helm_release.cert-manager,
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

  # scf-config-values
  set {
    name  = "env.DOMAIN"
    value = var.cap_domain
  }
  set {
    name  = "env.UAA_HOST"
    value = "uaa.${var.cap_domain}"
  }
  set_sensitive {
    name = "secrets.CLUSTER_ADMIN_PASSWORD"
    value = var.stratos_admin_password
  }
  set_sensitive {
    name = "secrets.UAA_ADMIN_CLIENT_SECRET"
    value = var.uaa_admin_client_secret
  }
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
  depends_on = [
    helm_release.scf,
    kubernetes_namespace.stratos
  ]
}

resource "null_resource" "update_stratos_dns" {
  provisioner "local-exec" {
    command = "/bin/sh modules/services/ext-dns-stratos-svc-annotate.sh"

    environment = {
      "KUBECONFIG"            = var.kubeconfig_file_path
      "AWS_ACCESS_KEY_ID"     = var.access_key_id
      "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
      "DOMAIN"                = var.cap_domain
    }
  }
  depends_on = [helm_release.stratos]
}

resource "null_resource" "wait_for_uaa" {
  provisioner "local-exec" {
    command = "/bin/sh modules/services/wait_for_uaa.sh"

    environment = {
      "KUBECONFIG"            = var.kubeconfig_file_path
      "AWS_ACCESS_KEY_ID"     = var.access_key_id
      "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
      "METRICS_API_ENDPOINT"  = var.cap_domain
    }
  }
  depends_on = [helm_release.stratos]
}

resource "helm_release" "metrics" {
  name       = "susecf-metrics"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "metrics"
  namespace  = "metrics"
  wait       = "false"

  values = [file(local.stratos_metrics_config_file)]
  set {
    name = "kubernetes.apiEndpoint"
    value = var.cap_domain
  }
  set {
    name = "cloudFoundry.apiEndpoint"
    value = "api.${var.cap_domain}"
  }
  set_sensitive {
    name = "nginx.password"
    value = var.metrics_admin_password
  }
  set_sensitive {
    name  = "cloudFoundry.uaaAdminClientSecret"
    value = var.uaa_admin_client_secret
  }

  depends_on = [
    null_resource.wait_for_uaa,
    kubernetes_namespace.metrics
  ]
}

resource "null_resource" "update_metrics_dns" {
  provisioner "local-exec" {
    command = "/bin/sh modules/services/ext-dns-metrics-svc-annotate.sh"

    environment = {
      "KUBECONFIG"            = var.kubeconfig_file_path
      "AWS_ACCESS_KEY_ID"     = var.access_key_id
      "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
      "DOMAIN"                = var.cap_domain
    }
  }

  depends_on = [helm_release.metrics]
}

