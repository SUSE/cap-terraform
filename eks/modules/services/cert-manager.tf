resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }
  }
}

resource "null_resource" "cert_manager_setup" {
  depends_on = [
    helm_release.nginx_ingress,
    kubernetes_namespace.cert_manager
  ]

  provisioner "local-exec" {
    command = "/bin/sh modules/services/setup_cert_manager.sh"
    environment = {
      "KUBECONFIG" = var.kubeconfig_file_path
      "AWS_ACCESS_KEY_ID" = var.access_key_id
      "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
    }
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  wait       = "true"
  version    = "0.8.1"

  set {
    name  = "global.rbac.create"
    value = "true"
  }

  # webhook seems flaky and frequently runs into intermittent errors due to various race conditions
  # https://docs.cert-manager.io/en/latest/getting-started/troubleshooting.html?highlight=internal%20server%20error#troubleshooting-installation

  set {
    name  = "webhook.enabled"
    value = "false"
  }

  depends_on = [
    local_file.kubeconfig_file,
    null_resource.cert_manager_setup
  ]
}

resource "null_resource" "cluster_issuer_setup" {
  depends_on = [
    helm_release.cert-manager,
    local_file.le_prod_cert_issuer
  ]

  provisioner "local-exec" {
    command = "/bin/sh modules/services/setup_cert_issuer.sh"
    environment = {
      "KUBECONFIG"            = var.kubeconfig_file_path
      "AWS_ACCESS_KEY_ID"     = var.access_key_id
      "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
    }
  }
}
