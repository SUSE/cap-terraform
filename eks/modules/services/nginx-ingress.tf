# Install Nginx Ingress using Helm Chart
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes-charts.suse.com/"
  chart      = "nginx-ingress"
  wait       = "false"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  # wait until the worker nodes have joined the cluster...
  depends_on = [
    local_file.kubeconfig_file,
    kubernetes_cluster_role_binding.tiller
  ]

}
