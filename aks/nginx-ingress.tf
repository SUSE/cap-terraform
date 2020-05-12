# Add Kubernetes Stable Helm charts repo
data "helm_repository" "bitnami" {
  name = "bitnami"
  url  = "https://charts.bitnami.com/bitnami"
}

# Install Nginx Ingress using Helm Chart
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = data.helm_repository.bitnami.metadata[0].url
  chart      = "nginx-ingress-controller"
  wait = "false"

  set {
    name  = "rbac.create"
    value = "true"
  }

# Note if you use the chart from kube helm repository the following must be "controller.service.externalTrafficPolicy"

  set {
    name  = "service.externalTrafficPolicy"
    value = "Local"
  }
# Note if you use the chart from kube helm repository the following must be "controller.publishService.enabled"

  set {
      name =  "publishService.enabled"
      value = "true"
  }

  depends_on = [helm_release.external-dns]
}