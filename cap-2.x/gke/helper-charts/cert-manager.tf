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

  content = templatefile("${path.module}/gke-le-cert-issuer.yaml.tmpl", {
    email   = var.email,
    project = var.project
  })
  filename = "${path.module}/gke-le-cert-issuer.yaml"
}

resource "null_resource" "cluster_issuer_setup" {
  depends_on = [local_file.le-cert-issuer,
    helm_release.cert-manager
  ]

  provisioner "local-exec" {

    command     = "./helper-charts/gke_setup_cert_issuer.sh"
    working_dir = "."
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG  = "${path.cwd}/kubeconfig"
      CERT_FILE   = "${path.module}/gke-le-cert-issuer.yaml"

    }
  }
}
