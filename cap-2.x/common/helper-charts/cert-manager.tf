resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  wait             = "true"
  version          = "v1.0.1"
  create_namespace = true

  set {
    name  = "global.rbac.create"
    value = "true"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }

}

resource "local_file" "le-cert-issuer" {

  content = templatefile("${path.module}/${var.platform}-le-cert-issuer.yaml.tmpl", {
    email             = var.email,
    project           = var.project
    client_id         = var.client_id,
    subscription_id   = var.subscription_id,
    tenant_id         = var.tenant_id,
    az_resource_group = var.dns_zone_resource_group,
    dns_zone_name     = var.dns_zone_name
  })
  filename = "${path.module}/${var.platform}-le-cert-issuer.yaml"
}

/* resource "kubernetes_secret" "cert-manager-secret" {
  metadata {
    name = "azuredns-config"
    namespace = "cert-manager"
  }

  data = {
     name = "CLIENT_SECRET"
     value = var.client_secret
  }

  depends_on = [helm_release.cert-manager]

} */

resource "null_resource" "cluster_issuer_setup" {
  depends_on = [local_file.le-cert-issuer,
    helm_release.cert-manager
  ]

  provisioner "local-exec" {

    command     = "./common/helper-charts/${var.platform}_setup_cert_issuer.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]
    environment = {
      AZ_CERT_MGR_SP_PWD = var.client_secret
      KUBECONFIG         = "${path.cwd}/kubeconfig"
      CERT_FILE          = "${path.module}/${var.platform}-le-cert-issuer.yaml"

    }
  }
}



