resource "null_resource" "cert_manager_setup" {
  depends_on = [helm_release.nginx_ingress]

  provisioner "local-exec" {
    command = "./setup_cert_manager.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]
    environment = {
      RESOURCE_GROUP = var.resource_group
      CLUSTER_NAME   = azurerm_kubernetes_cluster.k8s.name
      KUBECONFIG     = local.kubeconfig_file_path
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

resource "local_file" "le-cert-issuer" {
  depends_on = [helm_release.cert-manager]

  content = templatefile("${path.module}/le-cert-issuer.yaml.tmpl", {
    email = var.email,
    client_id = var.client_id,
    subscription_id = var.subscription_id,
    tenant_id = var.tenant_id,
    az_resource_group = var.dns_zone_resource_group,
    dns_zone_name = var.dns_zone_name
  })
  filename = "${path.module}/le-cert-issuer.yaml"
}

resource "null_resource" "cluster_issuer_setup" {
  depends_on = [local_file.le-cert-issuer]

  provisioner "local-exec" {
    command = "./setup_cert_issuer.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]
    environment = {
      RESOURCE_GROUP     = var.dns_zone_resource_group
      CLUSTER_NAME       = azurerm_kubernetes_cluster.k8s.name
      AZ_CERT_MGR_SP_PWD = var.client_secret
      KUBECONFIG         = local.kubeconfig_file_path

    }
  }
}

