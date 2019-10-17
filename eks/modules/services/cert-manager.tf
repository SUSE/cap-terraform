resource "null_resource" "cert_manager_setup" {
  depends_on = ["helm_release.nginx_ingress"]

  provisioner "local-exec" {
    command = "/bin/sh modules/services/setup_cert_manager.sh"
    environment = {
        "KUBECONFIG" = "${var.kubeconfig_path}"
    }
  }
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "${data.helm_repository.jetstack.metadata.0.name}"
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
    name = "webhook.enabled"
    value = "false"
  }
  
  depends_on = ["local_file.kubeconfig_file", "null_resource.cert_manager_setup"]
}

resource "null_resource" "cluster_issuer_setup" {
    depends_on = ["helm_release.cert-manager"]

    provisioner "local-exec" {
      command = "/bin/sh modules/services/setup_cert_issuer.sh"
      environment = {
        "KUBECONFIG" = "${var.kubeconfig_path}"
    }
  }
}
