locals {
  chart_values_file           = "${path.cwd}/scf-config-values.yaml"
  stratos_metrics_config_file = "${path.cwd}/stratos-metrics-values.yaml"
}

# Install UAA using Helm Chart
resource "helm_release" "uaa" {
  name       = "scf-uaa"
  repository = data.helm_repository.suse.metadata[0].name
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
  set {
    name = "secrets.CLUSTER_ADMIN_PASSWORD"
    value = var.stratos_admin_password
  }
  set {
    name = "secrets.UAA_ADMIN_CLIENT_SECRET"
    value = var.uaa_admin_client_secret
  }

  depends_on = [
    helm_release.external-dns,
    helm_release.nginx_ingress,
    helm_release.cert-manager,
    null_resource.cluster_issuer_setup
  ]
}

resource "helm_release" "scf" {
  name       = "scf-cf"
  repository = data.helm_repository.suse.metadata[0].name
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
  set {
    name = "secrets.CLUSTER_ADMIN_PASSWORD"
    value = var.stratos_admin_password
  }
  set {
    name = "secrets.UAA_ADMIN_CLIENT_SECRET"
    value = var.uaa_admin_client_secret
  }
  depends_on = [
    helm_release.external-dns,
    helm_release.nginx_ingress,
    helm_release.cert-manager,
    helm_release.uaa
  ]
}

resource "helm_release" "stratos" {
  name       = "susecf-console"
  repository = data.helm_repository.suse.metadata[0].name
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
  set {
    name = "secrets.CLUSTER_ADMIN_PASSWORD"
    value = var.stratos_admin_password
  }
  set {
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
  depends_on = [helm_release.scf]
}

resource "null_resource" "update_stratos_dns" {
  provisioner "local-exec" {
    command = "./modules/services/ext-dns-stratos-svc-annotate.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]

    environment = {
      DOMAIN        = var.cap_domain
    }
  }
  depends_on = [helm_release.stratos]
}

resource "null_resource" "wait_for_uaa" {
  provisioner "local-exec" {
    command = "./modules/services/wait_for_uaa.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]

    environment = {
      METRICS_API_ENDPOINT = var.cap_domain
    }
  }
  depends_on = [helm_release.stratos]
}

resource "helm_release" "metrics" {
  name       = "susecf-metrics"
  repository = data.helm_repository.suse.metadata.0.name
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
  set {
    name = "nginx.password"
    value = var.metrics_admin_password
  }

  depends_on = [null_resource.wait_for_uaa]
}

resource "null_resource" "update_metrics_dns" {
  provisioner "local-exec" {
    command = "./modules/services/ext-dns-metrics-svc-annotate.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]

    environment = {
      DOMAIN = var.cap_domain
    }
  }

  depends_on = [helm_release.metrics]
}

