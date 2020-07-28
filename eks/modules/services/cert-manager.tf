resource "local_file" "le_cert_issuer" {
  content = templatefile("${path.module}/le-cert-issuer.yaml.tmpl", {
    email = var.email,
    hosted_zone_id = var.hosted_zone_id,
    region = var.region,
    zone = var.hosted_zone_name
  })
  filename = "${path.module}/le-cert-issuer.yaml"
}

resource "kubernetes_namespace" "cert_manager" {
  depends_on = [kubernetes_config_map.aws_auth]

  metadata {
    name = "cert-manager"

    labels = {
      "cert-manager.io/disable-validation" = "true"
    }
  }

  timeouts {
    delete = "30m"
  }
}

resource "null_resource" "cert_manager_setup" {
  depends_on = [
    helm_release.nginx_ingress,
    local_file.le_cert_issuer,
    local_file.kubeconfig_file,
    kubernetes_namespace.cert_manager
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml"

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

resource "null_resource" "cluster_issuer_setup" {
  depends_on = [
    helm_release.cert-manager,
    local_file.le_cert_issuer,
    local_file.kubeconfig_file
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/le-cert-issuer.yaml"

    environment = {
      "KUBECONFIG"            = var.kubeconfig_file_path
      "AWS_ACCESS_KEY_ID"     = var.access_key_id
      "AWS_SECRET_ACCESS_KEY" = var.secret_access_key
    }
  }
}
