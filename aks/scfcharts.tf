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

resource "null_resource" "create_scf_namespaces" {
  depends_on = [azurerm_kubernetes_cluster.k8s, kubernetes_namespace.uaa, kubernetes_namespace.scf, kubernetes_namespace.stratos, kubernetes_namespace.metrics]
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
    null_resource.create_scf_namespaces
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

  depends_on = [helm_release.uaa]
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

  depends_on = [helm_release.scf]
}

resource "null_resource" "update_stratos_dns" {
  provisioner "local-exec" {
    command = "./ext-dns-stratos-svc-annotate.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]

    environment = {
      RESOURCE_GROUP     = var.dns_zone_resource_group
      CLUSTER_NAME       = azurerm_kubernetes_cluster.k8s.name
      AZ_CERT_MGR_SP_PWD = var.client_secret
      DOMAIN             = var.cap_domain
      KUBECONFIG         = local.kubeconfig_file_path
    }
  }
  depends_on = [helm_release.stratos]
}

resource "null_resource" "wait_for_uaa" {
  provisioner "local-exec" {
    command = "./wait_for_uaa.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]

    environment = {
      METRICS_API_ENDPOINT = var.cap_domain
      KUBECONFIG = local.kubeconfig_file_path
    }
  }
  depends_on = [helm_release.stratos]
}

resource "helm_release" "metrics" {
  name       = "susecf-metrics"
  repository = "https://kubernetes-charts.suse.com"
  chart      = "metrics"
  version    = "1.2.1"
  namespace  = "metrics"
  wait       = "false"

  values = [file(local.stratos_metrics_config_file)]
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

  depends_on = [null_resource.wait_for_uaa]
}

resource "null_resource" "update_metrics_dns" {
  provisioner "local-exec" {
    command = "./ext-dns-metrics-svc-annotate.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]

    environment = {
      RESOURCE_GROUP     = var.dns_zone_resource_group
      CLUSTER_NAME       = azurerm_kubernetes_cluster.k8s.name
      AZ_CERT_MGR_SP_PWD = var.client_secret
      DOMAIN             = var.cap_domain
      KUBECONFIG         = local.kubeconfig_file_path
    }
  }

  depends_on = [helm_release.metrics]
}

