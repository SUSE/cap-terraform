# Install Nginx Ingress using Helm Chart
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  wait       = "false"

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
      name =  "controller.publishService.enabled"
      value = "true"
  }

  # Make sure the nginx LB service gets a static, non-ephemeral (regional) IP.
  set {
      name = "controller.service.loadBalancerIP"
      value = google_compute_address.ingress-ext-address.address
  }

  depends_on = [helm_release.external-dns]

}
