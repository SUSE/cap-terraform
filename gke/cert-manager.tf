resource "local_file" "le_cert_issuer" {
  content = templatefile("le-cert-issuer.yaml.tmpl", {
    email = var.email,
    project = var.project,
  })
  filename = "le-cert-issuer.yaml"
}

resource "null_resource" "cert_manager_setup" {
  depends_on = [
    helm_release.nginx_ingress,
    local_file.le_cert_issuer
  ]

  provisioner "local-exec" {
    command = "/bin/sh setup_cert_manager.sh"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  wait       = "true"
  version    = "0.14.0"

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

  depends_on = [null_resource.cert_manager_setup]
}

resource "local_file" "dns_credentials" {
  content = var.dns_credentials_json
  filename = "dns_credentials.json"
}

resource "null_resource" "cluster_issuer_setup" {
  depends_on = [helm_release.cert-manager]

  provisioner "local-exec" {
    command = "/bin/sh setup_cert_issuer.sh"
  }
}

