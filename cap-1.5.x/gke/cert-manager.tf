resource "local_file" "le_cert_issuer" {
  content = templatefile("le-cert-issuer.yaml.tmpl", {
    email = var.email,
    project = var.project,
  })
  filename = "le-cert-issuer.yaml"
}

resource "kubernetes_namespace" "cert-manager" {
  depends_on = [google_container_node_pool.np]

  metadata {
    name = "cert-manager"

    labels = {
      "cert-manager.io/disable-validation" = "true"
    }
  }

  timeouts {
    delete = "15m"
  }
}

resource "null_resource" "cert_manager_setup" {
  depends_on = [
    helm_release.nginx_ingress,
    local_file.le_cert_issuer,
    local_file.kubeconfig,
    kubernetes_namespace.cert-manager
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml"

    environment = {
      KUBECONFIG = "./kubeconfig"
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

resource "local_file" "dns_credentials" {
  content = var.dns_credentials_json
  filename = "dns_credentials.json"
}

resource "kubernetes_secret" "dns_credentials" {
  depends_on = [
    kubernetes_namespace.cert-manager,
  ]

  metadata {
    name = "clouddns-dns01-solver-svc-acct"
    namespace = "cert-manager"
  }

  data = {
    "dns_credentials.json" = var.dns_credentials_json
  }
}

resource "null_resource" "cluster_issuer_setup" {
  depends_on = [
    helm_release.cert-manager,
    local_file.le_cert_issuer,
    local_file.kubeconfig,
    kubernetes_secret.dns_credentials
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f le-cert-issuer.yaml"

    environment = {
      KUBECONFIG = "./kubeconfig"
    }
  }
}

