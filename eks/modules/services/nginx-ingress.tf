# Add Kubernetes Stable Helm charts repo


data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

# Install Nginx Ingress using Helm Chart
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "nginx-ingress"
  # a hack for now to get around the inter-module dependency mess - ingress deployment has to wait
  # until all the aws resources have deployed.
  wait       = "true"
  timeout    = "600"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
      name =  "controller.publishService.enabled"
      value = "true"
  }
# wait until the worker nodes have joined the cluster...
  depends_on = ["kubernetes_config_map.aws_auth"]

}