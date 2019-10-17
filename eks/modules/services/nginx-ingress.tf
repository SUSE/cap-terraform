# Add Kubernetes Stable Helm charts repo


data "helm_repository" "suse" {
  name = "suse"
  url  = "https://kubernetes-charts.suse.com/"
}

# Install Nginx Ingress using Helm Chart
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "${data.helm_repository.suse.metadata.0.name}"
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
      name =  "controller.publishService.enabled"
      value = "true"
  }
  
  # wait until the worker nodes have joined the cluster...
  depends_on = ["local_file.kubeconfig_file", "kubernetes_cluster_role_binding.tiller"]

}