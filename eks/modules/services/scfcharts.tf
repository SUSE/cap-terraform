locals {
  chart_values_file           = "${path.module}/scf-config-values.yaml"
  stratos_metrics_config_file = "${path.module}/stratos-metrics-values.yaml"
}

resource "kubernetes_namespace" "uaa" {
  depends_on = [kubernetes_config_map.aws_auth]
 
  metadata {
    name = "uaa"
  }

  timeouts {
    delete = "30m"
  }
}

resource "kubernetes_namespace" "scf" {
  depends_on = [kubernetes_config_map.aws_auth]

  metadata {
    name = "scf"
  }

  timeouts {
    delete = "30m"
  }
}

resource "kubernetes_namespace" "stratos" {
  depends_on = [kubernetes_config_map.aws_auth]

  metadata {
    name = "stratos"
  }

  timeouts {
    delete = "30m"
  }
}

resource "kubernetes_namespace" "metrics" {
  depends_on = [kubernetes_config_map.aws_auth]

  metadata {
    name = "metrics"
  }

  timeouts {
    delete = "30m"
  }
}

# Install UAA using Helm Chart
resource "helm_release" "uaa" {
  depends_on = [
    helm_release.external-dns,
    helm_release.nginx_ingress,
    helm_release.cert-manager,
    kubernetes_namespace.uaa
  ]

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
}

resource "helm_release" "scf" {
  depends_on = [
    helm_release.uaa,
    kubernetes_namespace.scf
  ]

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
}

resource "helm_release" "stratos" {
  depends_on = [
    helm_release.scf,
    kubernetes_namespace.stratos
  ]

  name       = "susecf-console"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "console"
  version    = "3.2.0"
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
}

resource "null_resource" "wait_for_uaa" {
  depends_on = [helm_release.uaa]

  provisioner "local-exec" {
    command = "${path.module}/wait_for_url.sh"

    environment = {
      URL = "https://uaa.${var.cap_domain}/.well-known/openid-configuration"
    }
  }
}

provider "helm" {
  alias = "metrics"
  version = "1.0.0"

  kubernetes {
    config_path = var.kubeconfig_file_path
  }
}

resource "helm_release" "metrics" {
  depends_on = [
    helm_release.stratos,
    kubernetes_namespace.metrics,
    null_resource.wait_for_uaa
  ]

  provider   = helm.metrics
  name       = "susecf-metrics"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "metrics"
  version    = "1.2.1"
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
}

resource "null_resource" "update_stratos_dns" {
  depends_on = [
    helm_release.stratos,
    local_file.kubeconfig_file
  ]

  provisioner "local-exec" {
    command = "kubectl annotate svc susecf-console-ui-ext -n stratos  \"external-dns.alpha.kubernetes.io/hostname=stratos.${var.cap_domain}\""

    environment = {
      "KUBECONFIG"            = var.kubeconfig_file_path
      "AWS_ACCESS_KEY_ID"     = var.access_key_id
      "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
    }
  }
}

resource "null_resource" "update_metrics_dns" {
  depends_on = [
    helm_release.metrics,
    local_file.kubeconfig_file
  ]

  provisioner "local-exec" {
    command = "kubectl annotate svc susecf-metrics-metrics-nginx -n metrics  \"external-dns.alpha.kubernetes.io/hostname=metrics.${var.cap_domain}\""

    environment = {
      "KUBECONFIG"            = var.kubeconfig_file_path
      "AWS_ACCESS_KEY_ID"     = var.access_key_id
      "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
    }
  }
}
