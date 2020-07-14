locals {
  chart_values_file           = "${path.cwd}/scf-config-values.yaml"
  stratos_metrics_config_file = "${path.cwd}/stratos-metrics-values.yaml"
  # One variable is applied to all three security contexts,
  # override to create distinct passwords for each context
  stratos_admin_password      = var.admin_password
  uaa_admin_client_secret     = var.admin_password
  metrics_admin_password      = var.admin_password
}

resource "kubernetes_namespace" "uaa" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "uaa"
  }

  timeouts {
    delete = "15m"
  }
}

resource "kubernetes_namespace" "scf" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "scf"
  }

  timeouts {
    delete = "15m"
  }
}

resource "kubernetes_namespace" "stratos" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "stratos"
  }

  timeouts {
    delete = "15m"
  }
}

resource "kubernetes_namespace" "metrics" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "metrics"
  }

  timeouts {
    delete = "15m"
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
    name  = "secrets.UAA_ADMIN_CLIENT_SECRET"
    value = local.uaa_admin_client_secret
  }

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
    name  = "secrets.CLUSTER_ADMIN_PASSWORD"
    value = local.stratos_admin_password
  }
  set_sensitive {
    name  = "secrets.UAA_ADMIN_CLIENT_SECRET"
    value = local.uaa_admin_client_secret
  }

  depends_on = [
    helm_release.uaa,
    kubernetes_namespace.scf
  ]
}

resource "helm_release" "stratos" {
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

resource "null_resource" "wait_for_uaa" {
  depends_on = [helm_release.uaa]

  provisioner "local-exec" {
    command = "./wait_for_url.sh"

    environment = {
      URL = "https://uaa.${var.cap_domain}/.well-known/openid-configuration"
    }
  }
}

resource "helm_release" "metrics" {
  depends_on = [
    helm_release.stratos,
    kubernetes_namespace.metrics,
    null_resource.wait_for_uaa
  ]

  name       = "susecf-metrics"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "metrics"
  version    = "1.2.1"
  namespace  = "metrics"
  wait       = "false"

  values = [file(local.stratos_metrics_config_file)]
  #scf-metrics-values
  set {
    name = "metrics.username"
    value = "admin"
  }
  set_sensitive {
    name = "metrics.password"
    value = local.metrics_admin_password
  }
  set {
    name = "kubernetes.apiEndpoint"
    value = var.cap_domain
  }
  set {
    name = "cloudFoundry.apiEndpoint"
    value = "api.${var.cap_domain}"
  }
  set_sensitive {
    name  = "cloudFoundry.uaaAdminClientSecret"
    value = local.uaa_admin_client_secret
  }
}

resource "null_resource" "update_stratos_dns" {
  provisioner "local-exec" {
    command = "kubectl annotate svc susecf-console-ui-ext -n stratos  \"external-dns.alpha.kubernetes.io/hostname=stratos.${var.cap_domain}\""

    environment = {
      KUBECONFIG = "./kubeconfig"
    }
  }
  depends_on = [
    helm_release.stratos,
    local_file.kubeconfig
  ]
}

resource "null_resource" "update_metrics_dns" {
  provisioner "local-exec" {
    command = "kubectl annotate svc susecf-metrics-metrics-nginx -n metrics  \"external-dns.alpha.kubernetes.io/hostname=metrics.${var.cap_domain}\""

    environment = {
      KUBECONFIG = "./kubeconfig"
    }
  }
  depends_on = [
    helm_release.metrics,
    local_file.kubeconfig
  ]
}

output "uaa_url" {
  value = "https://uaa.${var.cap_domain}/login"
}
output "stratos_url" {
  value = "https://stratos.${var.cap_domain}"
}
output "metrics_url" {
  value = "https://metrics.${var.cap_domain}"
}
